#!/usr/bin/perl

use strict;
use warnings;

# turn off output buffering
$| = 1;

package MyWidget;
use Data::Dumper;
use IO::Select;
use QtGui4;
use QtCore4;
use QtCore4::isa qw( Qt::Widget );
use QtCore4::slots handle_signal_input => [],
    set_vert_sensitivity => ['double'],
    set_horz_sensitivity => ['double'],
    set_vert_baseline => ['double'],
    set_horz_baseline => ['double'],
    set_baseline_running_average => [],
    set_baseline_current_base_chan => [],
    set_baseline_manual => [],
    start_trial => [];
use QtCore4::signals
    x_average_changed => ['double'],
    y_average_changed => ['double'],
    base_chan_changed => ['double'],
    x_distance_changed => ['int'],
    y_distance_changed => ['int'],
    vert_baseline_changed => ['double'],
    horz_baseline_changed => ['double'],
    time_remaining_changed => ['int'];

our $square_size = 50;
our $target_duration = 20;
our $trial_duration = $target_duration * 9;
our $targets = {
    1 => { x => 100, y => 500 },
    2 => { x => 500, y => 500 },
    3 => { x => 100, y => 100 },
    4 => { x => 500, y => 100 },
    5 => { x => 300, y => 300 },
    6 => { x => 300, y => 500 },
    7 => { x => 100, y => 300 },
    8 => { x => 300, y => 100 },
    9 => { x => 500, y => 300 },
};

sub NEW {
    my ( $class, $parent ) = @_;
    $class->SUPER::NEW($parent);
    this->{_x}        = 45;
    this->{_x_signal} = 0;
    this->{_y}        = 45;
    this->{_y_signal} = 0;
    this->{selector}  = IO::Select->new();
    this->{selector}->add( \*STDIN );
    this->{chan1_samples} = [];
    this->{chan1_sum}     = 0;
    this->{chan2_samples} = [];
    this->{chan2_sum}     = 0;
    this->{_x_sensitivity} = 0.25;
    this->{_y_sensitivity} = 0.75;
    this->{_x_baseline} = 1;
    this->{_y_baseline} = 1;
    this->{base_chan} = 0;
    this->{_baseline_type} = 'base_chan';
    this->{_trial_width} = 600;
    this->{_trial_height} = 600;
    this->{_target_size} = $square_size;
    this->{_x_target} = 0;
    this->{_y_target} = 0;
    this->{_trial_finish} = Qt::Time::currentTime()->addSecs(-1);
}

sub sizeHint {
    return Qt::Size( this->{_trial_width}, this->{_trial_height} );
}

sub paintEvent {
    my $painter = Qt::Painter(this);

    # draw border
    my $size    = this->size();
    $painter->drawRect( 0, 0, $size->width() - 1, $size->height() - 1 );

    # draw target
    my $time = Qt::Time::currentTime();
    my $secs = $time->secsTo(this->{_trial_finish});
    if ($secs >= 0) {
        my $width   = this->{_target_size};
        my $height  = this->{_target_size};
        my $x       = this->{_x_target};
        my $y       = this->{_y_target};
        $painter->fillRect( $x, $y, $width, $height, Qt::Color( 0x00, 0xFF, 0x00 ) );
    }

    # draw cursor
    my $width   = $square_size;
    my $height  = $square_size;
    my $x       = this->{_x};
    my $y       = this->{_y};
    $painter->fillRect( $x, $y, $width, $height, Qt::Color( this->rgb() ) );

    $painter->end();
}

sub scale_x {
    return 100000 * this->{_x_sensitivity};
}

sub scale_y {
    return 100000 * this->{_y_sensitivity};
}

sub dead_zone {
    return 0.01;
}

sub wrap_pointer {
    return 0;
}

sub _scaled_to_0_to_255 {
    my ($velocity) = @_;
    $velocity = abs($velocity);
    my $scaled = int( 255 * ( $velocity / 10 ) );
    if ( $scaled > 255 ) {
        return 255;
    }
    return $scaled;
}

sub rgb {
    my $red  = _scaled_to_0_to_255( this->{_x_signal} );
    my $blue = _scaled_to_0_to_255( this->{_y_signal} );
    return ( $red, 0x00, $blue );
}

our $valid_row_regex = qr/
   (?<chan1>-?[0-9]+(?:\.[0-9]*)),\s*
   (?<chan2>-?[0-9]+(?:\.[0-9]*)),\s*
   (?<chan3>-?[0-9]+(?:\.[0-9]*))
/x;

sub set_vert_sensitivity {
    my ($newValue) = @_;
    this->{_y_sensitivity} = $newValue;
}

sub set_horz_sensitivity {
    my ($newValue) = @_;
    this->{_x_sensitivity} = $newValue;
}

sub set_vert_baseline {
    my ($newValue) = @_;
    my $oldValue = this->{_y_baseline};

    this->{_y_baseline} = $newValue;

    if ($newValue != $oldValue) {
        emit vert_baseline_changed($newValue);
    }
}

sub set_horz_baseline {
    my ($newValue) = @_;
    my $oldValue = this->{_x_baseline};

    this->{_x_baseline} = $newValue;

    if ($newValue != $oldValue) {
        emit horz_baseline_changed($newValue);
    }
}

sub start_trial {
    this->{_trial_finish} = Qt::Time::currentTime()->addSecs($trial_duration);
}

sub set_baseline_running_average {
    this->{_baseline_type} = 'running_avg';
}

sub set_baseline_current_base_chan {
    this->{_baseline_type} = 'base_chan';
}

sub set_baseline_manual {
    this->{_baseline_type} = 'manual';
}

sub use_current_average {
    my $num_samples = scalar @{ this->{chan1_samples} };

    this->set_horz_baseline(this->{chan1_sum} / $num_samples);
    this->set_vert_baseline(this->{chan2_sum} / $num_samples);
}

sub use_base_chan {
    this->set_horz_baseline(this->{base_chan});
    this->set_vert_baseline(this->{base_chan});
}

sub handle_signal_input {
    if ( not this->{selector}->can_read(0.0) ) {
        return;
    }
    my $time = Qt::Time::currentTime();
    my $secs = $time->secsTo(this->{_trial_finish});
    my $trial = 9 - int($secs / $target_duration);
    my $target = $targets->{$trial};
    if ($target) {
        this->{_x_target} = $target->{x} - this->{_target_size} / 2;
        this->{_y_target} = $target->{y} - this->{_target_size} / 2;
    }

    while ( this->{selector}->can_read(0.0) ) {
        my $line = readline( \*STDIN );
        last if not $line;
        if ( $line =~ m/$valid_row_regex/ ) {
            my $chan_1 = $+{chan1};
            my $chan_2 = $+{chan2};

            this->{base_chan} = $+{chan3};

            push @{ this->{chan1_samples} }, $chan_1;
            this->{chan1_sum} += $chan_1;
            push @{ this->{chan2_samples} }, $chan_2;
            this->{chan2_sum} += $chan_2;

            my $num_samples = scalar @{ this->{chan1_samples} };

            if ( $num_samples > 1000 ) {
                my $drop = shift @{ this->{chan1_samples} };
                this->{chan1_sum} -= $drop;
                $drop = shift @{ this->{chan2_samples} };
                this->{chan2_sum} -= $drop;
            }
            emit x_average_changed(this->{chan1_sum} / $num_samples);
            emit y_average_changed(this->{chan2_sum} / $num_samples);
            emit base_chan_changed(this->{base_chan});
            if (this->{_baseline_type} eq 'running_avg') {
                this->use_current_average();
            }
            elsif (this->{_baseline_type} eq 'base_chan') {
                this->use_base_chan();
            }

            this->{_x_signal} = ( this->scale_x() * (
                    $chan_1 - this->{_x_baseline} ) );
            this->{_y_signal} = ( this->scale_y() * (
                    $chan_2 - this->{_y_baseline} ) );
            my $dead_zone = this->dead_zone();

            if ( this->{_x_signal} > $dead_zone ) {
                this->{_x} += this->{_x_signal} - $dead_zone;
            }
            elsif ( this->{_x_signal} < -$dead_zone ) {
                this->{_x} += this->{_x_signal} + $dead_zone;
            }
            if ( this->{_y_signal} > $dead_zone ) {
                this->{_y} += this->{_y_signal} - $dead_zone;
            }
            elsif ( this->{_y_signal} < -$dead_zone ) {
                this->{_y} += this->{_y_signal} + $dead_zone;
            }

            this->{_x} = int(this->{_x});
            this->{_y} = int(this->{_y});

            my $size = this->size();
            if ( this->{_x} < 0 ) {
                if ( this->wrap_pointer() ) {
                    this->{_x} += $size->width() - $square_size;
                }
                else {
                    this->{_x} = 0;
                }
            }
            elsif ( this->{_x} > $size->width() - $square_size ) {
                if ( this->wrap_pointer() ) {
                    this->{_x} -= $size->width() - $square_size;
                }
                else {
                    this->{_x} = $size->width() - $square_size;
                }
            }
            if ( this->{_y} < 0 ) {
                if ( this->wrap_pointer() ) {
                    this->{_y} += $size->height() - $square_size;
                }
                else {
                    this->{_y} = 0;
                }
            }
            elsif ( this->{_y} > $size->height() - $square_size ) {
                if ( this->wrap_pointer() ) {
                    this->{_y} -= $size->height() - $square_size;
                }
                else {
                    this->{_y} = $size->height() - $square_size;
                }
            }
        }
        chomp $line;
        print $line, ',',
            this->{_x}, ',', this->{_x_target}, ',',
            this->{_y}, ',' , this->{_y_target}, ',',
            $time->msecsTo(this->{_trial_finish}),
            "\n";
    }
    if ($target) {
        emit x_distance_changed(this->{_x} - this->{_x_target});
        emit y_distance_changed(this->{_y} - this->{_y_target});
        emit time_remaining_changed($time->secsTo(this->{_trial_finish}));
    }
    elsif (this->{_x_target} != 0) {
        this->{_x_target} = 0;
        this->{_y_target} = 0;
        emit x_distance_changed(0);
        emit y_distance_changed(0);
        emit time_remaining_changed(0);
    }
    this->update();
}

package main;

use QtCore4;
use QtGui4;

my $app = Qt::Application( \@ARGV );
my $frame = Qt::Widget();
my $boxDisplay = MyWidget->new();
my $layout = Qt::HBoxLayout($frame);
my $controlPanelLayout = Qt::VBoxLayout();
my $vertSensLabel = Qt::Label("Vert Sensitivity");
my $vertSensSpin = Qt::DoubleSpinBox();
my $horzSensLabel = Qt::Label("Horz Sensitivity");
my $horzSensSpin = Qt::DoubleSpinBox();
my $vertBaseLabel = Qt::Label("Vert Baseline");
my $vertBaseSpin = Qt::DoubleSpinBox();
my $horzBaseLabel = Qt::Label("Horz Baseline");
my $horzBaseSpin = Qt::DoubleSpinBox();
my $startTrial = Qt::PushButton("Start trial");
my $averageLabel = Qt::Label("Average Signal:");
my $xAverage = Qt::Label("XX");
my $yAverage = Qt::Label("XX");
my $baseChanLabel = Qt::Label("Baseline channel:");
my $baseChan = Qt::Label("XX");
my $useAveragesRadio = Qt::RadioButton("Running Average");
my $useBaselineChanRadio = Qt::RadioButton("Baseline Channel");
my $useManualRadio = Qt::RadioButton("Manual");
my $baselineGroupbox = Qt::GroupBox("Baseline type");
my $baselineLayout = Qt::VBoxLayout();
my $distanceLabel = Qt::Label("Distance to Target:");
my $xDistance = Qt::Label("XX");
my $yDistance = Qt::Label("XX");
my $timeRemainingLabel = Qt::Label("Time remaining:");
my $timeRemaining = Qt::Label("XX");

$baselineLayout->addWidget($useAveragesRadio);
$baselineLayout->addWidget($useBaselineChanRadio);
$baselineLayout->addWidget($useManualRadio);
$baselineGroupbox->setLayout($baselineLayout);

$controlPanelLayout->addWidget($vertSensLabel);
$controlPanelLayout->addWidget($vertSensSpin);
$controlPanelLayout->addWidget($horzSensLabel);
$controlPanelLayout->addWidget($horzSensSpin);
$controlPanelLayout->addWidget($vertBaseLabel);
$controlPanelLayout->addWidget($vertBaseSpin);
$controlPanelLayout->addWidget($horzBaseLabel);
$controlPanelLayout->addWidget($horzBaseSpin);
$controlPanelLayout->addWidget($averageLabel);
$controlPanelLayout->addWidget($xAverage);
$controlPanelLayout->addWidget($yAverage);
$controlPanelLayout->addWidget($baseChanLabel);
$controlPanelLayout->addWidget($baseChan);
$controlPanelLayout->addWidget($baselineGroupbox);
$controlPanelLayout->addStretch();
$controlPanelLayout->addWidget($distanceLabel);
$controlPanelLayout->addWidget($xDistance);
$controlPanelLayout->addWidget($yDistance);
$controlPanelLayout->addWidget($timeRemainingLabel);
$controlPanelLayout->addWidget($timeRemaining);
$controlPanelLayout->addWidget($startTrial);
$layout->addLayout($controlPanelLayout);
$layout->addWidget($boxDisplay);
$frame->setLayout($layout);
$frame->show();

$vertSensSpin->setSingleStep( 0.1 );
$vertSensSpin->setValue( $boxDisplay->{_x_sensitivity} );
$horzSensSpin->setSingleStep( 0.1 );
$horzSensSpin->setValue( $boxDisplay->{_y_sensitivity} );
$vertBaseSpin->setSingleStep( 1e-4 );
$vertBaseSpin->setValue( $boxDisplay->{_x_baseline} );
$vertBaseSpin->setDecimals(10);
$horzBaseSpin->setSingleStep( 1e-4 );
$horzBaseSpin->setValue( $boxDisplay->{_y_baseline} );
$horzBaseSpin->setDecimals(10);

$boxDisplay->connect( $vertSensSpin, SIGNAL 'valueChanged(double)', $boxDisplay, SLOT 'set_vert_sensitivity(double)' );
$boxDisplay->connect( $horzSensSpin, SIGNAL 'valueChanged(double)', $boxDisplay, SLOT 'set_horz_sensitivity(double)' );
$boxDisplay->connect( $vertBaseSpin, SIGNAL 'valueChanged(double)', $boxDisplay, SLOT 'set_vert_baseline(double)' );
$boxDisplay->connect( $horzBaseSpin, SIGNAL 'valueChanged(double)', $boxDisplay, SLOT 'set_horz_baseline(double)' );
$boxDisplay->connect( $boxDisplay, SIGNAL 'vert_baseline_changed(double)', $vertBaseSpin, SLOT 'setValue(double)' );
$boxDisplay->connect( $boxDisplay, SIGNAL 'horz_baseline_changed(double)', $horzBaseSpin, SLOT 'setValue(double)' );
$boxDisplay->connect( $startTrial, SIGNAL 'pressed()', $boxDisplay, SLOT 'start_trial()' );
$boxDisplay->connect( $boxDisplay, SIGNAL 'x_average_changed(double)', $xAverage, SLOT 'setNum(double)' );
$boxDisplay->connect( $boxDisplay, SIGNAL 'y_average_changed(double)', $yAverage, SLOT 'setNum(double)' );
$boxDisplay->connect( $boxDisplay, SIGNAL 'base_chan_changed(double)', $baseChan, SLOT 'setNum(double)' );
$boxDisplay->connect( $useAveragesRadio, SIGNAL 'clicked(bool)', $boxDisplay, SLOT 'set_baseline_running_average()' );
$boxDisplay->connect( $useBaselineChanRadio, SIGNAL 'clicked(bool)', $boxDisplay, SLOT 'set_baseline_current_base_chan()' );
$boxDisplay->connect( $useManualRadio, SIGNAL 'clicked(bool)', $boxDisplay, SLOT 'set_baseline_manual()' );
$boxDisplay->connect( $boxDisplay, SIGNAL 'x_distance_changed(int)', $xDistance, SLOT 'setNum(int)' );
$boxDisplay->connect( $boxDisplay, SIGNAL 'y_distance_changed(int)', $yDistance, SLOT 'setNum(int)' );
$boxDisplay->connect( $boxDisplay, SIGNAL 'time_remaining_changed(int)', $timeRemaining, SLOT 'setNum(int)' );

my $timer = Qt::Timer($boxDisplay);
$boxDisplay->connect( $timer, SIGNAL 'timeout()', $boxDisplay, SLOT 'handle_signal_input()' );
$timer->start(10);

exit $app->exec();

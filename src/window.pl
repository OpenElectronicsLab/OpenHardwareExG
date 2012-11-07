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
    start_trial => [];
use QtCore4::signals
    x_distance_changed => ['int'],
    y_distance_changed => ['int'],
    time_remaining_changed => ['int'];

our $square_size = 50;
our $trial_duration = 20;

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
    this->{_trial_width} = 600;
    this->{_trial_height} = 600;
    this->{_target_size} = $square_size;
    this->{_x_target} = 100 - this->{_target_size} / 2;
    this->{_y_target} = 500 - this->{_target_size} / 2;
    this->{_trial_finish} = Qt::Time::currentTime();
}

sub trialInProgress {
    return Qt::Time::currentTime().secsTo(this->{_trial_finish}) >= 0;
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
    my $width   = this->{_target_size};
    my $height  = this->{_target_size};
    my $x       = this->{_x_target};
    my $y       = this->{_y_target};
    $painter->fillRect( $x, $y, $width, $height, Qt::Color( 0x00, 0xFF, 0x00 ) );

    # draw cursor
    $width   = $square_size;
    $height  = $square_size;
    $x       = this->{_x};
    $y       = this->{_y};
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
   (?<chan2>-?[0-9]+(?:\.[0-9]*))
/x;

sub set_vert_sensitivity {
    my ($newValue) = @_;
    this->{_y_sensitivity} = $newValue;
}

sub set_horz_sensitivity {
    my ($newValue) = @_;
    this->{_x_sensitivity} = $newValue;
}

sub start_trial {
    this->{_trial_finish} = Qt::Time::currentTime()->addSecs($trial_duration);
}

sub handle_signal_input {
    if ( not this->{selector}->can_read(0.0) ) {
        return;
    }
    while ( this->{selector}->can_read(0.0) ) {
        my $line = readline( \*STDIN );
        last if not $line;
        print $line, "\n";
        if ( $line =~ m/$valid_row_regex/ ) {
            my $chan_1 = $+{chan1};
            my $chan_2 = $+{chan2};

            push @{ this->{chan1_samples} }, $chan_1;
            this->{chan1_sum} += $chan_1;
            push @{ this->{chan2_samples} }, $chan_2;
            this->{chan2_sum} += $chan_2;

            my $samples = scalar @{ this->{chan1_samples} };

            if ( $samples > 1000 ) {
                my $drop = shift @{ this->{chan1_samples} };
                this->{chan1_sum} -= $drop;
                $drop = shift @{ this->{chan2_samples} };
                this->{chan2_sum} -= $drop;
            }
            my $chan1_avg = this->{chan1_sum} / $samples;
            my $chan2_avg = this->{chan2_sum} / $samples;

            this->{_x_signal} = ( this->scale_x() * ( $chan_1 - $chan1_avg ) );
            this->{_y_signal} = ( this->scale_y() * ( $chan_2 - $chan2_avg ) );
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
    }
    emit x_distance_changed(this->{_x} - this->{_x_target});
    emit y_distance_changed(this->{_y} - this->{_y_target});
    emit time_remaining_changed(Qt::Time::currentTime()->secsTo(this->{_trial_finish}));
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
my $vertLabel = Qt::Label("Vert");
my $vertSpin = Qt::DoubleSpinBox();
my $horzLabel = Qt::Label("Horz");
my $horzSpin = Qt::DoubleSpinBox();
my $startTrial = Qt::PushButton("Start trial");
my $distanceLabel = Qt::Label("Distance to Target:");
my $xDistance = Qt::Label("XX");
my $yDistance = Qt::Label("XX");
my $timeRemainingLabel = Qt::Label("Time remaining:");
my $timeRemaining = Qt::Label("XX");
$controlPanelLayout->addWidget($vertLabel);
$controlPanelLayout->addWidget($vertSpin);
$controlPanelLayout->addWidget($horzLabel);
$controlPanelLayout->addWidget($horzSpin);
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

$vertSpin->setSingleStep( 0.1 );
$vertSpin->setValue( $boxDisplay->{_x_sensitivity} );
$horzSpin->setSingleStep( 0.1 );
$horzSpin->setValue( $boxDisplay->{_y_sensitivity} );

$boxDisplay->connect( $vertSpin, SIGNAL 'valueChanged(double)', $boxDisplay, SLOT 'set_vert_sensitivity(double)' );
$boxDisplay->connect( $horzSpin, SIGNAL 'valueChanged(double)', $boxDisplay, SLOT 'set_horz_sensitivity(double)' );
$boxDisplay->connect( $startTrial, SIGNAL 'pressed()', $boxDisplay, SLOT 'start_trial()' );
$boxDisplay->connect( $boxDisplay, SIGNAL 'x_distance_changed(int)', $xDistance, SLOT 'setNum(int)' );
$boxDisplay->connect( $boxDisplay, SIGNAL 'y_distance_changed(int)', $yDistance, SLOT 'setNum(int)' );
$boxDisplay->connect( $boxDisplay, SIGNAL 'time_remaining_changed(int)', $timeRemaining, SLOT 'setNum(int)' );

my $timer = Qt::Timer($boxDisplay);
$boxDisplay->connect( $timer, SIGNAL 'timeout()', $boxDisplay, SLOT 'handle_signal_input()' );
$timer->start(10);

exit $app->exec();

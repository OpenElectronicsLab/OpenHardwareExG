#ifndef ADS1298_H
#define ADS1298_H

namespace ADS1298 {

    enum spi_command {
        // system commands
        WAKEUP  = 0x02,
        STANDBY = 0x04,
        RESET   = 0x06,
        START   = 0x08,
        STOP    = 0x0a,

        // read commands
        RDATAC  = 0x10,
        SDATAC  = 0x11,
        RDATA   = 0x12,

        // register commands
        RREG    = 0x20,
        WREG    = 0x40
    };

    enum reg {
        // device settings
        ID = 0x00,

        // global settings
        CONFIG1 = 0x01,
        CONFIG2 = 0x02,
        CONFIG3 = 0x03,
        LOFF    = 0x04,

        // channel specific settings
        CHnSET = 0x04,
        CH1SET = CHnSET + 1,
        CH2SET = CHnSET + 2,
        CH3SET = CHnSET + 3,
        CH4SET = CHnSET + 4,
        CH5SET = CHnSET + 5,
        CH6SET = CHnSET + 6,
        CH7SET = CHnSET + 7,
        CH8SET = CHnSET + 8,
        RLD_SENSEP = 0x0d,
        RLD_SENSEN = 0x0e,
        LOFF_SENSEP = 0x0f,
        LOFF_SENSEN = 0x10,
        LOFF_FLIP = 0x11,

        // lead off status
        LOFF_STATP = 0x12,
        LOFF_STATN = 0x13,

        // other
        GPIO = 0x14,
        PACE = 0x15,
        RESP = 0x16,
        CONFIG4 = 0x17,
        WCT1 = 0x18,
        WCT2 = 0x19
    };

    enum ID_bits {
        DEV_ID7 = 0x80,
        DEV_ID6 = 0x40,
        DEV_ID5 = 0x20,
        DEV_ID2 = 0x04,
        DEV_ID1 = 0x02,
        DEV_ID0 = 0x01,

        ID_const = 0x10
    };

    enum CONFIG1_bits {
        HR = 0x80,
        DAISY_EN = 0x40,
        CLK_EN = 0x20,
        DR2 = 0x04,
        DR1 = 0x02,
        DR0 = 0x01,

        CONFIG1_const = 0x00,
        HIGH_RES_4000_SPS = (HR | DR1 | DR0),
        HIGH_RES_500_SPS = (HR | DR2 | DR1),
        LOW_POWR_250_SPS = ( DR2 | DR1)
    };

    enum CONFIG2_bits {
        WCT_CHOP = 0x20,
        INT_TEST = 0x10,
        TEST_AMP = 0x04,
        TEST_FREQ1 = 0x02,
        TEST_FREQ0 = 0x01,

        CONFIG2_const = 0x00
    };

    enum CONFIG3_bits {
        PD_REFBUF = 0x80,
        VREF_4V = 0x20,
        RLD_MEAS = 0x10,
        RLDREF_INT = 0x08,
        PD_RLD = 0x04,
        RLD_LOFF_SENS = 0x02,
        RLD_STAT = 0x01,

        CONFIG3_const = 0x40
    };

    enum LOFF_bits {
        COMP_TH2 = 0x80,
        COMP_TH1 = 0x40,
        COMP_TH0 = 0x20,
        VLEAD_OFF_EN = 0x10,
        ILEAD_OFF1 = 0x08,
        ILEAD_OFF0 = 0x04,
        FLEAD_OFF1 = 0x02,
        FLEAD_OFF0 = 0x01,

        LOFF_const = 0x00
    };

    enum CHnSET_bits {
        PDn = 0x80,
        PD_n = 0x80,
        GAINn2 = 0x40,
        GAINn1 = 0x20,
        GAINn0 = 0x10,
        MUXn2 = 0x04,
        MUXn1 = 0x02,
        MUXn0 = 0x01,

        CHnSET_const = 0x00,
        TEST_SIGNAL = (MUXn2 | MUXn0),
        GAIN_1X = GAINn0
    };

    enum CH1SET_bits {
        PD_1 = 0x80,
        GAIN12 = 0x40,
        GAIN11 = 0x20,
        GAIN10 = 0x10,
        MUX12 = 0x04,
        MUX11 = 0x02,
        MUX10 = 0x01,

        CH1SET_const = 0x00
    };

    enum CH2SET_bits {
        PD_2 = 0x80,
        GAIN22 = 0x40,
        GAIN21 = 0x20,
        GAIN20 = 0x10,
        MUX22 = 0x04,
        MUX21 = 0x02,
        MUX20 = 0x01,

        CH2SET_const = 0x00
    };

    enum CH3SET_bits {
        PD_3 = 0x80,
        GAIN32 = 0x40,
        GAIN31 = 0x20,
        GAIN30 = 0x10,
        MUX32 = 0x04,
        MUX31 = 0x02,
        MUX30 = 0x01,

        CH3SET_const = 0x00
    };

    enum CH4SET_bits {
        PD_4 = 0x80,
        GAIN42 = 0x40,
        GAIN41 = 0x20,
        GAIN40 = 0x10,
        MUX42 = 0x04,
        MUX41 = 0x02,
        MUX40 = 0x01,

        CH4SET_const = 0x00
    };

    enum CH5SET_bits {
        PD_5 = 0x80,
        GAIN52 = 0x40,
        GAIN51 = 0x20,
        GAIN50 = 0x10,
        MUX52 = 0x04,
        MUX51 = 0x02,
        MUX50 = 0x01,

        CH5SET_const = 0x00
    };

    enum CH6SET_bits {
        PD_6 = 0x80,
        GAIN62 = 0x40,
        GAIN61 = 0x20,
        GAIN60 = 0x10,
        MUX62 = 0x04,
        MUX61 = 0x02,
        MUX60 = 0x01,

        CH6SET_const = 0x00
    };

    enum CH7SET_bits {
        PD_7 = 0x80,
        GAIN72 = 0x40,
        GAIN71 = 0x20,
        GAIN70 = 0x10,
        MUX72 = 0x04,
        MUX71 = 0x02,
        MUX70 = 0x01,

        CH7SET_const = 0x00
    };

    enum CH8SET_bits {
        PD_8 = 0x80,
        GAIN82 = 0x40,
        GAIN81 = 0x20,
        GAIN80 = 0x10,
        MUX82 = 0x04,
        MUX81 = 0x02,
        MUX80 = 0x01,

        CH8SET_const = 0x00
    };

    enum RLD_SENSP_bits {
        RLD8P = 0x80,
        RLD7P = 0x40,
        RLD6P = 0x20,
        RLD5P = 0x10,
        RLD4P = 0x08,
        RLD3P = 0x04,
        RLD2P = 0x02,
        RLD1P = 0x01,

        RLD_SENSP_const = 0x00
    };

    enum RLD_SENSN_bits {
        RLD8N = 0x80,
        RLD7N = 0x40,
        RLD6N = 0x20,
        RLD5N = 0x10,
        RLD4N = 0x08,
        RLD3N = 0x04,
        RLD2N = 0x02,
        RLD1N = 0x01,

        RLD_SENSN_const = 0x00
    };

    enum LOFF_SENSP_bits {
        LOFF8P = 0x80,
        LOFF7P = 0x40,
        LOFF6P = 0x20,
        LOFF5P = 0x10,
        LOFF4P = 0x08,
        LOFF3P = 0x04,
        LOFF2P = 0x02,
        LOFF1P = 0x01,

        LOFF_SENSP_const = 0x00
    };

    enum LOFF_SENSN_bits {
        LOFF8N = 0x80,
        LOFF7N = 0x40,
        LOFF6N = 0x20,
        LOFF5N = 0x10,
        LOFF4N = 0x08,
        LOFF3N = 0x04,
        LOFF2N = 0x02,
        LOFF1N = 0x01,

        LOFF_SENSN_const = 0x00
    };

    enum LOFF_FLIP_bits {
        LOFF_FLIP8 = 0x80,
        LOFF_FLIP7 = 0x40,
        LOFF_FLIP6 = 0x20,
        LOFF_FLIP5 = 0x10,
        LOFF_FLIP4 = 0x08,
        LOFF_FLIP3 = 0x04,
        LOFF_FLIP2 = 0x02,
        LOFF_FLIP1 = 0x01,

        LOFF_FLIP_const = 0x00
    };

    enum LOFF_STATP_bits {
        IN8P_OFF = 0x80,
        IN7P_OFF = 0x40,
        IN6P_OFF = 0x20,
        IN5P_OFF = 0x10,
        IN4P_OFF = 0x08,
        IN3P_OFF = 0x04,
        IN2P_OFF = 0x02,
        IN1P_OFF = 0x01,

        LOFF_STATP_const = 0x00
    };

    enum LOFF_STATN_bits {
        IN8N_OFF = 0x80,
        IN7N_OFF = 0x40,
        IN6N_OFF = 0x20,
        IN5N_OFF = 0x10,
        IN4N_OFF = 0x08,
        IN3N_OFF = 0x04,
        IN2N_OFF = 0x02,
        IN1N_OFF = 0x01,

        LOFF_STATN_const = 0x00
    };

    enum GPIO_bits {
        GPIOD4 = 0x80,
        GPIOD3 = 0x40,
        GPIOD2 = 0x20,
        GPIOD1 = 0x10,
        GPIOC4 = 0x08,
        GPIOC3 = 0x04,
        GPIOC2 = 0x02,
        GPIOC1 = 0x01,

        GPIO_const = 0x00
    };

    enum PACE_bits {
        PACEE1 = 0x10,
        PACEE0 = 0x08,
        PACEO1 = 0x04,
        PACEO0 = 0x02,
        PD_PACE = 0x01,

        PACE_const = 0x00
    };

    enum RESP_bits {
        RESP_DEMOD_EN1 = 0x80,
        RESP_MOD_EN1 = 0x40,
        RESP_PH2 = 0x10,
        RESP_PH1 = 0x08,
        RESP_PH0 = 0x04,
        RESP_CTRL1 = 0x02,
        RESP_CTRL0 = 0x01,

        RESP_const = 0x20
    };

    enum CONFIG4_bits {
        RESP_FREQ2 = 0x80,
        RESP_FREQ1 = 0x40,
        RESP_FREQ0 = 0x20,
        SINGLE_SHOT = 0x08,
        WCT_TO_RLD = 0x04,
        PD_LOFF_COMP = 0x02,

        CONFIG4_const = 0x00
    };

    enum WCT1_bits {
        aVF_CH6 = 0x80,
        aVL_CH5 = 0x40,
        aVR_CH7 = 0x20,
        avR_CH4 = 0x10,
        PD_WCTA = 0x08,
        WCTA2 = 0x04,
        WCTA1 = 0x02,
        WCTA0 = 0x01,

        WCT1_const = 0x00
    };

    enum WCT2_bits {
        PD_WCTC = 0x80,
        PD_WCTB = 0x40,
        WCTB2 = 0x20,
        WCTB1 = 0x10,
        WCTB0 = 0x08,
        WCTC2 = 0x04,
        WCTC1 = 0x02,
        WCTC0 = 0x01,

        WCT2_const = 0x00
    };
};

#endif /* ADS1298_H */

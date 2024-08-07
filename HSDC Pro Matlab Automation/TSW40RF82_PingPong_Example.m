%The purpose of this script is to perform a ping-pong type execution of ADC
%sampling and DAC signal synthesis. One instance of HSDC Pro will be running while
%being connected to two TSW40RF8x EVMs and two TSW14xx boards.

%Configuration of TSW40RF8xs via respective GUI is required.

% Add folder into path that contains the Automation DLL
addpath(genpath('C:\Program Files (x86)\Texas Instruments\HSDC Pro Dual Capture Automation\Source Code\HSDC Pro Matlab Automation'));
% Load the Automation DLL
if ~libisloaded('HSDCProAutomation_64Bit')
    [notfound,warnings]=loadlibrary('C:\Program Files (x86)\Texas Instruments\HSDC Pro Dual Capture Automation\Source Code\HSDC Pro Matlab Automation\HSDCProAutomation_64Bit.dll', @HSDCProAutomationHeader);
end

%****ADC SETTINGS****%

% Board Serial Number with board type separated by hyphen. Eg: TIVHIV9Z-TSW1400
BoardSerialNumberADC = 'T81A3Fub-TSW14J56revD';
% Firmware file path which needs to be loaded to the board.
FirmwareFilePath = 'C:/Program Files (x86)/Texas Instruments/High Speed Data Converter Pro/14J56revD Details/Firmware/TSW14J56REVD_FIRMWARE.rbf';
ADCDevice = 'ADC32RF80_LMF_8821';
WaitToCheck=1; % Wait to check if firmware is downloaded properly? 0 - No, 1 - Yes. If yes, timeout should be greater than 60sec.
TimeoutInMs = 30000;
ADCOutputDataRate = 245.72e6;
ADCInputTargetFrequency = 0;
NumberOfSamplesPerChannel = 65536; % Smaller number of samples, faster execution time of script.
NumberOfSamplesForAnalysis = 16384;  %Keep smaller to reduce FFT time
ChannelIndex=0; % Interested channel's index(0-based)

% Trigger Settings
TriggerModeEnable=0; % Enable Trigger - 1; Disable Trigger - 0
SoftwareTriggerEnable=0; % Hardware Trigger - 0; Software Trigger - 1
ArmOnNextCaptureButtonPress = 0;
TriggerCLKDelays = 0; % The number of clock delays for the trigger
WaitToCheckTrigger = 1; % 0 - Don't Wait, 1 - Wait and check whether trigger has occurred.

FFTSettingsType = 1; % 0 - Rectangular ; 1 - Other Windows
NumberOfHarmonics = 5; % Number of harmonics to be considered
% Number of bins to remove on either side of the frequency
NoOfBinsToRemoveAfterDC = 1;
NoOfBinsToRemoveEitherSideOfHarmonics = 0;
NoOfBinsToRemoveEitherSideOfFundamental = 25;
% Custom frequency and the corresponding number of bins to remove for that frequency
CustomNotchFrequencies = [50000000, 25000000];
NoOfBinsToRemoveOnEitherSideOfCustomFrequencies = [25, 20];
NumberOfCustomFreq = 2; % Number of custom frequencies
% For Real FFT, FFT Array length is half the number of samples
% For Complex FFT, FFT Array length is equal to the number of samples
FFTArrayLength = 32768;
% Enable/Disable the automatic notching of (Fs/2 - Fin) frequency, when Fs/2 or Fin is changed.
enableFsby2MinusFinNotching = 0; % 0 - Disable, 1 - Enable
binsToRemoveOnEitherSideOfFsby2 = 10; % Number of Bins to remove on either side of (Fs/2 - Fin) frequency
% File Save Settings. Please provide file path with the respective extension
CSVFilePathWithName = 'C:/HSDCPro Data/ADCdata1.csv'; 
PNGFilePathWithName = 'C:/HSDCPro Data/ADCFFT1.png';
% Selection Settings
TestSelection = 1; % Time Domain-0; Single Tone-1; Two Tone-2; Channel Power-3
PlotType = 2; % Codes - 0; Bits - 1; Real FFT - 2; Complex FFT - 3
FFTWindowType = 3; % Rectangular - 0; Hamming - 1; Hanning - 2; Blackman - 3 
% Getting the Single Tone Parameters
% The parameters whose values are needed must be sent separated by ";" as a string(char array)
ParametersIn = 'SNR;SFDR;THD;SINAD;ENOB;Fund.;Next Spur;HD2;HD3;HD4;HD5;NSD';
ParameterValueLength = 12; % Size of "ParameterValues" array. Should be at least equal to the no. of parameters requested
dBFs = 1; % dBc - 0, dBFs - 1. Required Unit for Parameters - SNR, THD, SINAD, Next Spur and NSD

%****DAC SETTINGS****%

BoardSerialNumberDAC = 'T8130E9h-TSW14J56revD';
FirmwareFilePath = 'C:\Program Files (x86)\Texas Instruments\High Speed Data Converter Pro\14J56revD Details\Firmware\TSW14J56REVD_FIRMWARE.rbf';
WaitToCheck=1; % Wait to check if firmware is downloaded properly? 0 - No, 1 - Yes. If yes, timeout should be greater than 60sec.
DACDevice = 'DAC38RF8x_841'; % DAC device to be selected(should be same as what appears in the HSDC Pro GUI selection drop down box.

%DACDataRate = 245.72e6; % DAC output Data Rate
DACDataRate = 491.52e6;
DACPreamble = 0;
DACOption = 0; % 0 - 2's Complement, 1 - Offset Binary

TimeoutInMs = 30000; % TimeoutInMs for each function

ActiveChannelIndex=0; % Active channel index(0-based)

% Channel Enable/Disable Settings for each channel
% An array which specifies the enable/disable option for all DAC channels
% Channel Enable Settings array index corresponds to Channel Index. Array size should be same as the number of channels present in DAC.
%  0 - Disable, 1 - Enable
ChannelEnableSettings(1) = 1; % Channel Index 0 - Enable
ChannelEnableSettings(2) = 0; % Channel Index 1 - Enable
ChannelEnableSettings(3) = 0; % Channel Index 2 - Disable
ChannelEnableSettings(4) = 0; % Channel Index 3 - Enable
NumberOfChannels = 4; % Total Number of Channels for DAC

DACDataOption = 0; % 0 - DAC Data from File, 1 - DAC Data from DAC Tone Generation. Used by this example for easy use. 

% File Save Settings. Please provide DAC file path for Data
% Please remove the (x86) for 32-bit Systems.
%DACFilePath = 'C:\Program Files (x86)\Texas Instruments\High Speed Data Converter Pro\Test Files\single_tone_cmplx_32768_250MSPS__BW_25.1MHZ.csv'; 
DACFilePath = 'C:\HSDCPro Data\ADCdata1.csv';

% ********************************************************************************//
% ********** The actual call to the function contained in the dll ****************//
% ********************************************************************************//

%fprintf('\nPlease open the HSDCPro GUI before using these Automation DLL functions.');
%input('\nPress ENTER to start...');

n=1; %Adjust value of n to set number of loops. Comment the "while" below and "end" at bottom of script to remove looping.

while n <= 10

% Connecting to the board and selecting DAC device
fprintf('\n\nConnecting to board : %s',BoardSerialNumberADC);
[Error_Status] = calllib('HSDCProAutomation_64Bit','Connect_Board',BoardSerialNumberADC,TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status)); 

fprintf('\n\nSelecting ADC Device : %s',ADCDevice);
[Error_Status] = calllib('HSDCProAutomation_64Bit','Select_ADC_Device',ADCDevice,120000);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status)); 

% Download Firmware(OPTIONAL). Selecting device itself(above function) will automatically download the firmware
% fprintf('\n\nDownloading Firmware : %s',FirmwareFilePath);
% [Error_Status] = calllib('HSDCProAutomation_64Bit','Download_Firmware',FirmwareFilePath,WaitToCheck,60000);
% fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status)); 

fprintf('\n\nConfiguration Settings:');
fprintf('\n\nPassing ADC Output Data Rate = %d',ADCOutputDataRate);
[Error_Status] = calllib('HSDCProAutomation_64Bit','Pass_ADC_Output_Data_Rate',ADCOutputDataRate,TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status));

fprintf('\n\nADC Input Target Frequency = %d',ADCInputTargetFrequency);
[Error_Status] = calllib('HSDCProAutomation_64Bit','Set_ADC_Input_Target_Frequency',ADCInputTargetFrequency,TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status));

fprintf('\n\nNumber of Samples per Channel = %d',NumberOfSamplesPerChannel);
[Error_Status] = calllib('HSDCProAutomation_64Bit','Set_Number_of_Samples',NumberOfSamplesPerChannel,TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status));

fprintf('\n\nAnalysis Window Length = %d',NumberOfSamplesForAnalysis);
[Error_Status] = calllib('HSDCProAutomation_64Bit','ADC_Analysis_Window_Length',NumberOfSamplesForAnalysis,TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status));

fprintf('\n\nApplying FFT Notch Filter Settings');
[Error_Status] = calllib('HSDCProAutomation_64Bit','FFT_Window_Notching',FFTSettingsType, NumberOfHarmonics, NoOfBinsToRemoveEitherSideOfHarmonics,NoOfBinsToRemoveAfterDC, NoOfBinsToRemoveEitherSideOfFundamental,CustomNotchFrequencies,NoOfBinsToRemoveOnEitherSideOfCustomFrequencies,NumberOfCustomFreq,enableFsby2MinusFinNotching,binsToRemoveOnEitherSideOfFsby2,TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status));

fprintf('\n\nApplying Trigger Settings');
[Error_Status] = calllib('HSDCProAutomation_64Bit','Trigger_Option',TriggerModeEnable,SoftwareTriggerEnable,ArmOnNextCaptureButtonPress,TriggerCLKDelays,TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status));

% Data Acquisition
if TriggerModeEnable == 0 % Normal Capture
    %input('\n\nStart Normal Capture. Press ENTER to continue...');
    fprintf('\nStarting Normal Capture...');
    [Error_Status] = calllib('HSDCProAutomation_64Bit','Pass_Capture_Event',TimeoutInMs);
    fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status));
elseif (TriggerModeEnable==1 && SoftwareTriggerEnable==0) % External Hardware Trigger
    %input('\n\nRead DDR Memory. Press ENTER to continue...');
    fprintf('\nReading DDR Memory...');
    [Error_Status] = calllib('HSDCProAutomation_64Bit','Read_DDR_Memory',WaitToCheckTrigger,TimeoutInMs);
    fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status));
elseif (TriggerModeEnable==1 && SoftwareTriggerEnable==1) % Software Trigger
    %input('\n\nGenerate Software Trigger. Press ENTER to continue...');
    fprintf('\nGenerating Software Trigger...');
    [Error_Status] = calllib('HSDCProAutomation_64Bit','Generate_Software_Trigger',WaitToCheckTrigger,TimeoutInMs);
    fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status));
end

fprintf('\n\nChecking if HSDCPro GUI has completed all its operations...');
[Error_Status] = calllib('HSDCProAutomation_64Bit','HSDC_Ready',TimeoutInMs); % Waiting to check if HSDCPro has completed all its operations.
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status));

% fprintf('\n\nSaving ADC Raw Data as BIN file at %s', BINFilePathWithName);
% [Error_Status] = calllib('HSDCProAutomation_64Bit','ADC_Save_Raw_Data_As_Binary_File',BINFilePathWithName,TimeoutInMs);
% fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status)); 

fprintf('\n\nSaving ADC Raw Data as CSV file at %s', CSVFilePathWithName);
[Error_Status] = calllib('HSDCProAutomation_64Bit','Save_Raw_Data_As_CSV',CSVFilePathWithName,TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status)); 

% Applying FFT Settings
fprintf('\n\nTest Selection Option = %d (Time Domain-0; Single Tone-1; Two Tone-2; Channel Power-3)',TestSelection);
[Error_Status] = calllib('HSDCProAutomation_64Bit','ADC_Test_Selection',TestSelection,TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status)); 

fprintf('\n\nGraph Plot Type = %d (Codes - 0; Bits - 1; Real FFT - 2; Complex FFT - 3)',PlotType);
[Error_Status] = calllib('HSDCProAutomation_64Bit','ADC_Plot_Type',PlotType,TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status)); 

fprintf('\n\nFFT Window Type = %d (Rectangular - 0; Hamming - 1; Hanning - 2; Blackman - 3)',FFTWindowType);
[Error_Status] = calllib('HSDCProAutomation_64Bit','FFT_Window',FFTWindowType,TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status)); 

fprintf('\n\nSaving ADC FFT as PNG image at %s',PNGFilePathWithName);
[Error_Status] = calllib('HSDCProAutomation_64Bit','Save_FFT_As_PNG',ChannelIndex,PNGFilePathWithName,TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status)); 

fprintf('\n\nSelecting the ADC Channel Index = %d',ChannelIndex);
[Error_Status] = calllib('HSDCProAutomation_64Bit','Select_ADC_Channel',ChannelIndex,TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status));

fprintf('\n\nGetting the FFT Data of the active channel.');
f0 = [];
df = [];
ActiveChannelFFT = zeros(FFTArrayLength,1);
[Error_Status, f0, df, ActiveChannelFFT,FFTArrayLength] = calllib('HSDCProAutomation_64Bit','Get_FFT_Data',TimeoutInMs, f0, df, ActiveChannelFFT, FFTArrayLength);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status));

ParameterValues = zeros(ParameterValueLength,1);
fprintf('\n\nGetting the Single Tone Parameter Values.');
[Error_Status,ParametersIn,ParameterValues] = calllib('HSDCProAutomation_64Bit','Single_Tone_Parameters',ParametersIn,dBFs,TimeoutInMs,ParameterValues,ParameterValueLength);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status));
if (dBFs>0)
    ParamUnit = 'dBFs';
else
    ParamUnit = 'dBc';
end
fprintf('\nThe Parameter Values are:');
fprintf('\nSNR = %g %s',ParameterValues(1),ParamUnit);
fprintf('\nSFDR = %g dBc',ParameterValues(2));
fprintf('\nTHD = %g %s',ParameterValues(3),ParamUnit);
fprintf('\nSINAD = %g %s',ParameterValues(4),ParamUnit);
fprintf('\nENOB = %g Bits',ParameterValues(5));
fprintf('\nFund. = %g dBFs',ParameterValues(6));
fprintf('\nNext Spur = %g %s',ParameterValues(7),ParamUnit);
fprintf('\nHD2 = %g dBc',ParameterValues(8));
fprintf('\nHD3 = %g dBc',ParameterValues(9));
fprintf('\nHD4 = %g dBc',ParameterValues(10));
fprintf('\nHD5 = %g dBc',ParameterValues(11));
fprintf('\nNSD = %g %s/Bin',ParameterValues(12),ParamUnit);

% Disconnecting from the board
fprintf('\n\nDisconnecting from the board');
[Error_Status] = calllib('HSDCProAutomation_64Bit','Disconnect_Board',TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status)); 

% DAC Tone Generation Settings
% ToneBandwidth = 10000000; % Tone Bandwidth = 10M
% ToneCenter = 30000000; % The center frequency on either side of which, the DAC Tones are generated.
% ScalingFactor = 1; % Scaling Factor (1x)
% NumberOfTones = 5; % The total number of tones to be generated
% NumberOfSamples = 65536; % The number of samples for which the DAC Tone needs to be generated
% ToneSelection = 1; % 0 - Real, 1 - Complex


% Connecting to the board and selecting DAC device
fprintf('\n\nConnecting to board : %s',BoardSerialNumberDAC);
[Error_Status] = calllib('HSDCProAutomation_64Bit','Connect_Board',BoardSerialNumberDAC,TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status)); 

fprintf('\n\nSelecting DAC Device : %s',DACDevice);
[Error_Status] = calllib('HSDCProAutomation_64Bit','Select_DAC_Device',DACDevice,120000);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status)); 

% Download Firmware(OPTIONAL). Selecting device itself(above function) will automatically download the firmware
% fprintf('\n\nDownloading Firmware : %s',FirmwareFilePath);
% [Error_Status] = calllib('HSDCProAutomation_64Bit','Download_Firmware',FirmwareFilePath,WaitToCheck,60000);
% fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status)); 

% Configuration Settings
fprintf('\n\nConfiguration Settings:');
fprintf('\n\nDAC Data Rate = %g',DACDataRate);
[Error_Status] = calllib('HSDCProAutomation_64Bit','DAC_Data_Rate',DACDataRate,TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status)); 

fprintf('\n\nDACOption = %d (0 - 2''s Complement, 1 - Offset Binary)',DACOption);
[Error_Status] = calllib('HSDCProAutomation_64Bit','DAC_Option',DACOption,TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status)); 

fprintf('\n\nApplying Enable/Disable Settings for DAC Channels');
for i=1:NumberOfChannels
    fprintf('\nChannel Index[%d] = ',i-1);
    if(ChannelEnableSettings(i)>0)
        fprintf('Enabled');
    else
        fprintf('Disabled');
    end
end
[Error_Status] = calllib('HSDCProAutomation_64Bit','DAC_Channel_Enable_Settings',ChannelEnableSettings,NumberOfChannels,TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status));  

fprintf('\n\nDAC Active Channel Index = %d',ActiveChannelIndex);
[Error_Status] = calllib('HSDCProAutomation_64Bit','DAC_Active_Channel',ActiveChannelIndex,TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status));  

if DACDataOption == 0
    fprintf('\n\nDAC Data from File : %s',DACFilePath);
    [Error_Status] = calllib('HSDCProAutomation_64Bit','DAC_Load_File',DACFilePath,TimeoutInMs);
    fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status)); 
else 
    fprintf('\n\nGenerating Data from DAC Tone Generation');
    [Error_Status] = calllib('HSDCProAutomation_64Bit','DAC_Tone_Generation',ToneBandwidth,NumberOfTones,ToneCenter,NumberOfSamples,ToneSelection,ScalingFactor,TimeoutInMs);
    fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status));  
end

fprintf('\n\nDAC Preamble = %d',DACPreamble);
[Error_Status] = calllib('HSDCProAutomation_64Bit','DAC_Preamble',DACPreamble,TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status)); 

fprintf('\n\nSending Data to DAC');
[Error_Status] = calllib('HSDCProAutomation_64Bit','DAC_Send',TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status));  

% Disconnecting from the board
fprintf('\n\nDisconnecting from the board');
[Error_Status] = calllib('HSDCProAutomation_64Bit','Disconnect_Board',TimeoutInMs);
fprintf('\nError Status = %d (%s)',Error_Status,HSDCPro_Automation_Error_to_String(Error_Status)); 

n = n+1;
end
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

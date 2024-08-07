function [ Error_String ] = HSDCPro_Automation_Error_to_String( Error_Status )
%HSDCPRO_AUTOMATION_ERROR_TO_STRING Summary of this function goes here
%   Detailed explanation goes here
    
    if Error_Status == 0
        Error_String = 'No Error';
        return;
    end
    
    fid = fopen('../../../Automation DLL Error Codes.csv');
    if fid == -1
        Error_String = 'Could not open "Automation DLL Error Codes.csv"';
        return;
    end
    error_codes = textscan(fid,'%s','Delimiter',',');
    fclose(fid);
    
%     Start at 3 to skip the title row of the csv file
    for i = 3:2:length(error_codes{1})
        if Error_Status == str2num(error_codes{1}{i})
            Error_String = error_codes{1}{i+1};
            return;
        end
    end
    
    Error_String = 'Could not find error in "Automation DLL Error Codes.csv"';
end


function send_triggerIO64(address,condition)
    % address: defines the adress of the parallel port you want yo use in
    % hexadecimal
    % condition : your trigger number 
    
    %config_io
    ioObj = io64;
    status = io64(ioObj);
    io64(ioObj, address, condition);
    %data_out=0;
    WaitSecs(.02);  
    io64(ioObj, address, 0);
end


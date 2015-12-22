function out=clamp(in, value)
    % function will clamp the input to value
    out=in;
    if length(value)==1 % assume value is max value for clamp
        out(in > value)=value;
    elseif length(value)==2 % assume value is vector of min and max values for clamp
        out(in > value(2)) = value(2);
        out(in < value(1)) = value(1);
    end
end
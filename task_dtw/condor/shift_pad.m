%% shift_pad: function description
%% idx: -2 -1  0  1  2  3  4  5  6  7  8
%% ts1:        1  2  3  4  5  6
%% ts2:  1  2  3  
function [idx1_padded, idx2_padded] = shift_pad(len1, len2, idx)
    idx1_padded = 1:len1;
    idx2_padded = 1:len2;

    %% ts1 padding
    ts1_pad_head = [];
    if idx < 0
        ts1_pad_head = ones(1, -idx) * idx1_padded(1);
    end
    
    ts1_pad_tail = [];
    if idx+len2 > len1
        ts1_pad_tail = ones(1, idx+len2-len1) * idx1_padded(end);
    end
    idx1_padded = [ts1_pad_head idx1_padded ts1_pad_tail];

    %% ts2 padding
    ts2_pad_head = [];
    if idx > 0
        ts2_pad_head = ones(1, idx) * idx2_padded(1);
    end
    
    ts2_pad_tail = [];
    if idx+len2 < len1
        ts2_pad_tail = ones(1, len1-idx-len2) * idx2_padded(end);
    end
    idx2_padded = [ts2_pad_head idx2_padded ts2_pad_tail];
end

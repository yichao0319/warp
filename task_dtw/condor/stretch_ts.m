%% stretch_ts:
function [stretch_ts, stretch_idx] = stretch_ts(ts, itvl, inset)
    len_pad = itvl - mod(length(ts), itvl);
    pad = zeros(1, len_pad);

    stretch_ts = [ts, pad];
    stretch_idx = 1:(length(ts)+len_pad);

    stretch_ts = reshape(stretch_ts, itvl, []);
    stretch_idx = reshape(stretch_idx, itvl, []);

    dup_ts = repmat(stretch_ts(end, :), inset, 1);
    dup_idx = repmat(stretch_idx(end, :), inset, 1);

    stretch_ts = cat(1, stretch_ts, dup_ts);
    stretch_idx = cat(1, stretch_idx, dup_idx);

    stretch_ts = reshape(stretch_ts, 1, []);
    stretch_idx = reshape(stretch_idx, 1, []);

    stretch_ts = stretch_ts(1, 1:end-len_pad-inset);
    stretch_idx = stretch_idx(1, 1:end-len_pad-inset);
end


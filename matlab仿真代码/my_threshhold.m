
function level = my_threshhold(I)

I = im2uint8(I(:));
  num_bins = 256;
  counts = imhist(I,num_bins);
  level = otsuthresh(counts);
end
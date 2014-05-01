%calculatePrecisionRecall.m
%
%Garrett Warnell
%February 2014
%
%DESCRIPTION:
%    calculates the precision and recall for a saliency mask by varying a
%    binary thresholding operator over the [0 1] intensity interval
%
%INPUTS:
%    *S: the m-by-n saliency mask (values in [0 1])
%
%    *gt: the m-by-n ground truth (values in {0,1})
%
%    *n_thresh: the number of thresholds to use over the [0 1] interval
%
%OUTPUTS:
%    *p: an n_thresh-by-1 vector containing the precision values
%    corresponding to each thresholding
%
%    *r: an n_thresh-by-1 vector containing the recall values corresponding
%    to each thresholding

function [p, r] = precisionRecall(S,gt,n_thresh)

%compute thresholds
thresholds = 0:1/n_thresh:(1-1/n_thresh);

%determine total number of positive pixels
positive = sum(gt(:));

%loop thresholds and compute precision/recall
p = zeros(n_thresh,1);
r = zeros(n_thresh,1);
for t = 1:n_thresh
  %threshold the saliency map and determine number of salient pixels
  Sthresh = S>thresholds(t);
  %determine true positives and false positives
  truepositive = sum(Sthresh(:)&gt(:));
  falsepositive = sum(Sthresh(:)&(~gt(:)));
  %determine precision and recall
  p(t) = truepositive/(truepositive+falsepositive);
  r(t) = truepositive/positive;
end
function varargout = findContinuousSections(data,threshold)
% findContinuousSections  Find continuous sequences of values above a threshold
%   FINDCONTINUOUSSECTIONS finds start & end indices as well as lengths of 
%   continuous sequences of values larger than a given threshold.
%
%   Syntax
%     FINDCONTINUOUSSECTIONS(data, threshold)
%     sections = FINDCONTINUOUSSECTIONS(__)
%     [start, end, length] = FINDCONTINUOUSSECTIONS(__)
%
%   Description
%     FINDCONTINUOUSSECTIONS(data, threshold) finds the continuous sequences of
%       values in data that exceed a threshold threshold.
%     sections = FINDCONTINUOUSSECTIONS(__) returns the ranked continuous
%       sections start indices, end indices and length in one matrix.
%     [start, end, length] = FINDCONTINUOUSSECTIONS(__) returns the ranked 
%       continuous sections start indices, end indices and length as seperate
%       variables.
%
%   Example(s)
%     FINDCONTINUOUSSECTIONS([3 4 9 1 9 26], 2)
%
%
%   Input Arguments
%     data - data vector
%       numeric or logical vector or scalar
%         The data vector in which to find the continuous sections.
%
%     threshold - theshold value
%       numeric finite scalar
%         The threshold value. The function finds continuous sequences where 
%         data > threshold.
%
%
%   Output Arguments
%     sections - continuous sections as matrix
%       nx3 matrix
%         The continuous sections found, ranked descending by length. The first
%         column holds the start indices, the second the end indices and the
%         third the sequence length.
%
%     start - start indices
%       nx1 vector
%         Start indices of the found continuous sections ranked descending by 
%         section length.
%
%     end - end indices
%       nx1 vector
%         End indices of the found continuous sections ranked descending by 
%         section length.
%
%     legnth - section lengths
%       nx1 vector
%         Lenghts of the found continuous sections ranked descending by section
%         length.
%
%
%   Name-Value Pair Arguments
%
%
%   See also DIFF, FIND, SORTROWS
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    nargoutchk(0,3)
    
    % Input validation
    validateattributes(data,{'numeric','logical'},{'vector'},mfilename,'data',1)
    validateattributes(threshold,{'numeric'},{'scalar','finite'},mfilename,'threshold',2)
    
    % Make column vector
    data    = data(:);
    
    % Find section indices and length
    delta               = diff(cat(1,false, data > threshold, false));
    sectionStartIndex   = find(delta > 0);
    sectionEndIndex     = find(delta < 0) - 1;
    sectionLength       = sectionEndIndex - sectionStartIndex + 1;
    
    % Rank the sections by length
    sections    = cat(2,sectionStartIndex,sectionEndIndex,sectionLength);
    sections    = sortrows(sections,3,'descend');
    
    % Set ouputs
    if any(nargout == [0,1])
        varargout{1} = sections;
    elseif nargout > 1
        varargout{1} = sections(:,1);
        varargout{2} = sections(:,2);
        varargout{3} = sections(:,3);
    end
end

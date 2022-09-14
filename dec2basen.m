function S = dec2basen(D,b,s,varargin)
% dec2basen  Decimal integer to its base n representation using custom symbols
%   DEC2BASEN converts decimal integers to their base b representation using
%     symbols s.
%
%   Syntax
%     str = DEC2BASEN(D,b,s)
%     str = DEC2BASEN(D,b,s,minDigits)
%
%   Description
%     str = DEC2BASEN(D,b,s) converts a vector of decimal integers D into their
%       base b representation using the symbols specified as char row vector in
%       s and outputs the result as a char array S.
%     str = DEC2BASEN(D,b,s,minDigits) additionally pads the char array S to
%       hold at least minDigits digits.
%
%   Example(s)
%     str = DEC2BASEN(30,26,'ABCDEFGHIJKLMNOPQRSTUVWXYZ') returns 'AD'
%     str = DEC2BASEN(65,16,'0123456789ABCDEF',4) returns '0041'
%
%
%   Input Arguments
%     D - decimal intergers
%       vector of non-negative integers
%         Input decimal integer vector. D must be a non-negative integer vector
%         smaller than flintmax.
%
%     b - new base
%       scalar positive integer
%         The new base to which all elements in D should be converted to.
%
%     s - symobls
%       char row vector
%         The symbols that should be used for the base b representation of D.
%         Each char in s needs to be unique. S requires at least b unique
%         symbols. The symbols are used in the order that they are provided,
%         where S(1) represents the lowest value and S(end) represents the
%         highest value.
%         Some common symbol sets:
%           - hexadecimal: b = 16, s = '0123456789ABCDEF'
%           - Excel columns: b = 26, s = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
%           - binary: b = 2, s= '01'
%
%     minDigits - minimum digits
%       0 (default) | positive scalar integer
%         The number of digits that the output S should be padded to. If the
%         conversion requires more digits than minDigits, minDigits is ignored.
%         S(1) is used for padding.
%
%
%   Output Arguments
%     S - base b representation of D
%       char array
%         The base b represenation of D using symbols s.
%
%
%   Name-Value Pair Arguments
%
%
%   See also DEC2BASE, FLINTMAX, REM, FLOOR
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%
    
    narginchk(3,4)
    
    minDigits = 1;
    if nargin == 4
        minDigits = varargin{1};
    end
    
    validateattributes(D, {'numeric'}, {'vector','integer','nonnegative','finite'}, mfilename, 'D', 1)
    validateattributes(b, {'numeric'}, {'nonempty','scalar','integer','positive','finite'}, mfilename, 'base', 2)
    validateattributes(s, {'char'}, {'nonempty','row'}, mfilename, 'symbols', 3)
    validateattributes(minDigits, {'numeric'}, {'nonempty','scalar','integer','nonnegative','finite'}, mfilename, 'minDigits', 4)
    
    nSymbols = numel(s);
    
    % Assert max(D) does not exceed the maximum float consecutive integer precision
    assert(max(D) <= flintmax,...
        'Utilities:dec2basen:FlIntMaxExceeded',...
        'D exceeds flintmax.')

    % Assert unique symbols
    assert(nSymbols == numel(unique(s)),...
        'Utilities:dec2basen:NonUniqueSymbols',...
        'The ''symbols'' argument has to have unique entries.')
    
    % Assert sufficient unique symbols for given base
    assert(nSymbols >= b,...
        'Utilities:dec2basen:InsufficientUniqueSymbols',...
        'Not enough symbols for base %u: %u given, while %u are required.',b,nSymbols,b)
    
    % Prepare inputs
    D	= double(D(:));
    b  	= double(b);
    
    % Get the minimum number of digits required in base b to represent D.
    nDigits     = floor(log(max(D))/log(b)) + 1;
    
    % Honor minDigits input
    if nargin == 4
        nDigits = max(nDigits, minDigits);
    end
    
    % Initialize
    digit = nDigits;
    index(:,digit) = rem(D,b);
    
    % Go through the required digits
    while any(D) && digit > 1
        digit = digit - 1;
        D = floor(D/b);
        index(:,digit) = rem(D,b);
    end
    
    % Convert index into S
    S = reshape(s(index + 1),size(index));
end

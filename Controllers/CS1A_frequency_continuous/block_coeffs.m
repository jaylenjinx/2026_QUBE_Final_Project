function [b, a] = block_coeffs(Cz)
%BLOCK_COEFFS Difference-equation coefficients of a discrete SISO transfer function.
%   [b, a] = BLOCK_COEFFS(Cz) returns the numerator and denominator of Cz in
%   powers of z^-1, padded to equal length and scaled so that a(1) = 1, as the
%   CS1 controller block expects. Cz must be proper (a causal controller).
[b, a] = tfdata(Cz, 'v');
n = max(numel(b), numel(a));
b = [zeros(1, n - numel(b)), b];
a = [zeros(1, n - numel(a)), a];
k = find(a ~= 0, 1);
if isempty(k) || any(b(1:k-1) ~= 0)
    error('block_coeffs:improper', 'The controller must be proper (causal).');
end
b = b(k:end) / a(k);
a = a(k:end) / a(k);
end

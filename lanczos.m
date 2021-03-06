function x = lanczos(A, b, matfun, iter)
%--------------------------------------------------------------------------
% Classical Lanczos method for matrix function approximation
% Analyzed in e.g.: 
%   "Error analysis of the Lanczos algorithm for tridiagonalizing a 
%   symmetric matrix" -- Christopher Paige
%
% usage : 
%
%  input:
%  * A : symmetric matrix nxn matrix or a function afun(A,z) for
%  computing A*z for any vector z
%  * b : length n vector
%  * matfun : MATLAB handle for scalar function f(x) like 1/x, eps(x), sqrt(x), etc.
                % e.g. lanczos(A, b, @(z) 1/z, iter)
%  * iter : number of iterations, default 25
%
%  output:
%  * x : approximation to f(A)b
%--------------------------------------------------------------------------
if nargin > 4
    error('lanczos:TooManyInputs','requires at most 4 input arguments');
end
if nargin < 3
    error('lanczos:TooFewInputs','requires at least 3 input arguments');
end
if nargin < 4
    iter = 25;
end
if(iter < 1)
    error('lanczos:BadInput','one or more inputs outside required range');
end

if(~isa(A,'function_handle'))
    A = @(z) A*z;
end

n = length(b);

% Allocate space for Krylov subspace and tridiagonal matrix.
K = zeros(n,iter+1);
beta = zeros(1,iter);
alpha = zeros(1,iter);

% Build Krylov subspace
K(:,1) = b/norm(b);
beta(1) = 0;
K(:,2) = A(K(:,1));
alpha(1) = dot(K(:,2),K(:,1));
for i = 1:iter-1
    K(:,i+1) = K(:,i+1) - alpha(i)*K(:,i);
    beta(i+1) = norm(K(:,i+1));
    if(beta(i+1) == 0) break; end
    K(:,i+1) = K(:,i+1)/beta(i+1);
    K(:,i+2) = A(K(:,i+1)) - beta(i+1)*K(:,i);
    alpha(i+1) = dot(K(:,i+2),K(:,i+1));
end

T = spdiags([[beta(2:iter),0]' alpha' beta'], -1:1, iter, iter);
% TODO: replace with O(n^2) time algorithm from Gu, Eisenstat "A 
% divide-and-conquer algorithm for the symmetric tridiagonal eigenproblem."
[U,S] = eig(full(T));

% construct final approximation
fS = diag(arrayfun(matfun,diag(S)));
xall = norm(b)*K(:,1:iter)*U*fS*U';
x = xall(:,1);
end
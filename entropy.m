


f = inline('x*log2(x*20)', 'x');

syms x;

p=int (f(x),0,70);

p

% h = -r * e;
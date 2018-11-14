function tf = xconstraint(X)

tf1 = X.rise <= X.peak;
tf2 = X.peak <= X.fall;
tf = tf1 & tf2;

end
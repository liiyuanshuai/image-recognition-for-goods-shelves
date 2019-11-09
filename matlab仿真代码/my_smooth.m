function yy = my_smooth(x,span)

[m,n] = size(x);

if n == 1
    flag = 1;
    temp_x = x';
else 
    flag = 0;
    temp_x = x;
end
[m,n] = size(temp_x);

y = zeros(m,n);

for i = 1:(span-1)/2
    for j = 1:(2*i)-1
        y(i) = y(i) + x(j);
    end
    y(i) =  y(i) ./ (2*i-1);
end

for i = ((span-1)/2+1):n-(span-1)/2
    for j = 0:span-1
        y(i) = y(i) + x(i - (span-1)/2 + j);
    end
    y(i) = y(i)/span;
end

for i = n-(span-1)/2+1:n
    for j = i - (n-i):n
        y(i) = y(i) + x(j);
    end
    y(i) = y(i)/((n-i)*2+1);
end
if flag == 1
    yy = y';
else
    yy = y;
end
end
    


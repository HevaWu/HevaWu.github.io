---
layout: post
title: Akra-Bazzi Theorem
date: 2021-01-11 20:12:00
comment_id: 130
categories: [Math, Algorithm, Theorem]
tags: [Divide And Conquer]
---

> The Akra–Bazzi method, or Akra–Bazzi theorem, is used to analyze the asymptotic behavior of the mathematical recurrences that appear in the analysis of divide and conquer algorithms where the sub-problems have substantially different sizes. It is a generalization of the master theorem for divide-and-conquer recurrences, which assumes that the sub-problems have equal size.

## Formulation

$$\displaylines{ 
T(x)= 
\begin{cases}
\Theta(1) , if \ 1 <= x <= x_0 \\ 
g(x) + \Sigma_{i=1}^k a^i T(b_i x) + f_i (x), if \ x > x_0
\end{cases}
}$$

It follows:

- $x>=1$ is a real number
- $x_0$ is a constant, for $i=1,2,...,k, x_0 >= {1 \over b_i}, x_0 >= {1 \over 1-b_i}$
- for $i=1,2,...,k$, $a_i$ is a positive constant number
- for $i=1,2,...,k$, $a_i$ is a constant between $0< b_i < 1$
- $k >= 1$ is an integer
- $ g(x) \in O(x^c)$ where c is a constant
- $ f_i (x) \in O({x \over (log_2x)^2})$ for all $i$

If we find $p$ where $\Sigma_{i=1}^k a_i b_i^p = 1$, then:

$$T(n) \in \Theta(x^p(1+ \int_1^x {f(u) \over u^{p+1}}du ))$$

## Example

$$\displaylines{
T(n)=
\begin{cases}
1, when \ 0 <= n <= 3 \\
n^2 + {7 \over 4}T(\lfloor {1 \over 2} n \rfloor) + T(\lceil {3 \over 4} n\rceil), when \ n > 3
\end{cases}
}$$

Applying Akra-Bazzi method, find $p$ which $ {7 \over 4}({1 \over 2})^p + ({3 \over 4})^p = 1 $, in this example, $p=2$, using the formula:

$$\displaylines{
\begin{align}
T(n) & \in \Theta(x^p(1+ \int_1^x {f(u) \over u^{p+1}}du )) \\
& = \Theta(x^2 (1+ \int_1^x {u^2 \over u^3}du )) \\
& = \Theta(x^2(1+ \ln x)) \\
& = \Theta(x^2 \log x) \\
\end{align}
}$$

#### Reference

- <https://en.wikipedia.org/wiki/Akra%e2%80%93Bazzi_method>

# Income on inhomogeneous process

Assume the following scenario: An event company has announced an event set for a certain future date, and they have a set number of tickets available for the event. The company is interested in dynamically adjusting the ticket price as to maximize the income they obtain from ticket sales before the event happens.

## Problem specification

Assume that ticket purchases during the time between event announcement and the event can be modeled as an inhomogeneous poisson process. Bin the timespan from announcement to event into a discrete number of bins with length $\Delta$. 

The given constants are:

$$\left\{\begin{array}{l} T_0 = \text{Event announcement time} \\ T_1 = \text{Event time} \\ x = \text{Event attributes} \end{array} \right. $$

Variables of interest:

$$\left\{\begin{array}{l} \lambda_t = \text{Instantaneous sales rate at time} \ t \\ \Delta = \frac{T-t_0}{\text{#intervals}} = \text{Interval time} \\ p_t = \text{Ticket price at time} \  t\end{array} \right.$$

The instantaneous sales rate $\lambda_t$ depends on the event attributes, the time until the event and the ticket price $p_t$ at time $t$. We'll express the dependency as $\lambda_t=f(x, T_1-t, p_t)$. In reality, it likely depends on other factors, such as time during the year (people are more likely to spend money close after payday), etc. **This dependency is not known**, but has to be approximated from a dataset of ticket sales for past events $D = \left\{x_i, \left\{t, p_t\right\}_{t=t_0}^{t_1} \right\}_{i=1}^N$.

At time $T_0$, the expected income can be expressed as the following sum where the sequence of ticket prices $\left\{ p_t\right\}_{t=T_0}^{T_1}$ is known:

$$\mathbb{E}\left[\text{Income} \middle| \left\{ p_t\right\}_{t=T_0}^{T_1}\right] = \sum_{t=T_0}^{T_1}{\lambda_t \Delta p_t}$$

For subsequent times $t_i \in (T_0, T_1)$, or time bin indices $i \in (1, \text{#intervals})$, the expected *remaining* income can be modeled can be expressed as:

$$\mathbb{E}\left[\text{Remaining Income} \middle| \left\{ p_t\right\}_{t=t_i}^{T_1}   \right]_i = \sum_{t=t_i}^{T_1}{\lambda_t \Delta p_t}$$

The goal is to design a controller which for each discrete time step outputs the sequence of ticket prices $\left\{ p_t\right\}_{t=t_i}^{T_1}$ to set for the remaining time steps until the event as to maximize the expected remaining income. In order to achieve this goal, we first need to approximate how the instantaneous sales rate depends on relevant factors based on historical data.

### Problem specification summary

Two step process:

1. Find a function $f$ describing the instantaneous ticket sales rate such that $\lambda_t=f(x, T_1-t, p_t)$. 
2. In each time step $i$, solve the optimization problem $$\max_{\left\{ p_t\right\}_{t=t_i}^{T_1}} \sum_{t=t_i}^{T_1}{\lambda_t \Delta p_t}$$

## Sampling the actual income

The total income

  
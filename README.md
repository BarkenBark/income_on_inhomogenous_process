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
2. In each time step $i$, solve the optimization problem $$\max_{\left\{ p_t\right\}_{t=t_i}^{T_1}} \sum_{t=t_i}^{T_1}{\lambda_t \Delta p_t}$$ and use the first entry of th sequence as the current price

## Sampling the actual income

The total income

  # TODO:

- [x] Refactor Genetic Algorithm to a function
  - [x] Verify
- [x] Refactor DemandEstimation to a function
  - [x] Verify
- [x] Create function for estimating the time it takes to do N evaluations
- [x] Allow for time discretization with various bin width
  - [x] Refactor EvaluateIndividual such that it uses currentState.sequenceTimes rather than constant timeBinWidth assumption
  - [x] Decide if you want sequenceTimes to be expressed in time units until event, time units since posted or global time units. **Decision:** Roll with time units since posted for now.
- [x] Refactor fitness plotting to a function updating axis handle
- [x] Implement script using GA to optimize day-by-day
- [ ] Implement validation through stochastic simulation
- [x] In pricing sequence plot, add line marking where we expect the tickets to be sold out
- [ ] In pricing sequence plot, include some other closely performing individuals with thinner lines than the best performing one
- [x] Redefine sequenceTime such that is contains all bin edges including the right bin edge of the last bin
  - [ ] Also make sure the naming of this vector is consistent
- [ ] Make Chromosome representation of Pricing Sequence more efficient by exploiting the finite resolution and range

# QUESTIONS/ANALYSIS:

- Is there a risk that our evaluation function allows for pricing sequences where we just set very low prices before we get sold out, and that we count a bunch of tickets that we couldn't get sold in reality (due to depletion) towards our expected remaining income? (Probably yes)
  - Yes, hot damn. The GA solutions typically learned to "cheat" by doing exactly what described above. The solution was to make sure we only count the expected tickets sold beneath our sales capacity when evaluating. Now, the solutions tend to be more expensive such that we don't sell out.
- If the pricing sequence makes a huge leap in the middle of the sequence, this doesn't really affect the solution since the expected sales rate for that time bin will be 0. However, we definitely don't want pricings like this. 
  - Use reasonable pricing caps, forcing prices within the domain of prices having a real effect on the solution fitness
  - Enforce some constraint in chromosome decoding making it unable to spike
  - Capture the effect of too dynamic pricing in estimated demand function
  - Could we make genes that deviate the (global or local) mean have a higher mutation probability?
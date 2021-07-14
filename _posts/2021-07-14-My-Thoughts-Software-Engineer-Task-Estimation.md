---
layout: post
title: My Thoughts - Software Engineer Task Estimation
date: 2021-07-14 23:00:00
comment_id: 173
categories: [Project Management, My Thoughts]
---

In my opinion, as a Software Engineer, we should make a development estimation for each task. This article will record some my personal thoughts after looking through several articles.

## Why we should have task estimation

For planner/client:

- Each feature/product will have some rough budget there. It might be calculated as development total time * hourly rate.
- It is required to know how many people will join it.
- We need to know roughly development time, then we can schedule next tasks.

For engineer:

- Team could constantly have enough tasks to keep working. There might be a challenge to prioritize each tasks.
- Helps to clearly know the scope of work

## Things should Remember During Estimation

For getting a more properly/accurately estimation, it cannot simply decided by only engineer or only stakeholder. It is because one feature/product requirement might be changing. **The stakeholder should provide requirement information to development team, then, team can clarify the work scope and make a estimation.**

But, it is always hard to make a perfect estimation. Why?

### Parkinson’s Law

Based on [Parkinson’s Law](https://en.wikipedia.org/wiki/Parkinson%27s_law#:~:text=Parkinson's%20law%20is%20the%20adage,of%20bureaucracy%20in%20an%20organization.): `work expands so as to fill the time available for its completion`. Discussion can help identifying and minimizing potential issue, it is very important step but we also need to put this time into development estimation.

### All roads lead to Rome

When you plan to achieve a goal, in fact, there might be multiple ways to do it. Take an example, if you want to learn a new skill, it might take 1 year that study in school. OR, you might want to self-study it which might take 2 more years. Sometimes, it is really hard to define the bounds between different ways. One might be save time but cost lot, in contrast, one might cost little but take longer time.

### Software Development is a Process

I think there is no developer can 100% make sure everything will go smoothly as expectation. Like environment, performance, security, etc. Also, it is not limit on technical part. Other private or emergency issue might also happen, like getting sick, etc.

### Everyone is Different

Different engineer will give different self-estimation. It totally depends on each person's skill, experience, even physical state.

For trying to get a more perfect estimation, **we should review and correct it by more experienced tech-person.**

Here is the flow:

- Get required information. StakeHolder should provide feature plan and details, where developer should try to give use cases, mockups.
- Rough estimate the task. It'd be better give a range at here, ex: min time and max time, or best case and worst case. We can set a baseline which can help you balance it.
- Discovery period. We might need to show stakeholder prototype, if they have no info about the feature/project.

## Some Tips

- When there is any tasks >= 8 hours, we should try to see if we can split it into sub-taks. It would be better not make one single task take 30+ hours
- If one estimate is written by someone for himself/herself, it always suggested to let another person to help reviewing the estimates. This is because people are likely estimate own tasks slow 😆
- In the last calculation, we can leave some risk buffer time for each tasks. It can be a code review ,discussion time and unpredictability issue handling.
- To reduce overhead communication between developer team, one solution is to keep team sizes small and reasonable, generally 4–5 people. For teams that are larger, work should be distributed between sub-teams that have minimal overlap.

Based on info above, it might have a formula like:

$$
\text{Development Estimation} = \text{overall task time estimation(E)} + \text{E * risk buffer}
$$

We might always pick risk buffer from: 20% - 25%

## Estimate Approaches

- One person write esitmation, another person review
- [Planning Poker / Scrum Poker](https://en.wikipedia.org/wiki/Planning_poker)

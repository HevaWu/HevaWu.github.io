---
layout: post
title: Imperative programming & Declarative programming
date: 2020-11-25 21:54:00
comment_id: 114
categories: [Programming Paradigm]
tags: [imperative, declarative]
---

There are two main approaches to programming:

- Imperative programming – focuses on how to execute, defines control flow as statements that change a program state.
- Declarative programming – focuses on what to execute, defines program logic, but not detailed control flow.

# Imperative Programming

> `Imperative programming` is a programming paradigm that `uses statements that change a program's state`.

The imperative program consists of commands for the computer to perform and focuses on describing `how a program operates`.

## Procedural programming

A type of imperative programming. The program is built from one or more procedures(subroutines or functions).

Heavily procedural programming, in which state changes are localized to procedures or restricted to explicit arguments and returns from procedures, is a form of `structured programming`.

Procedural programming could be considered a step toward declarative programming. Programmer can often tell, simply by looking at the names, arguments, and return types of procedures.

# Declarative Programming

> `Declarative programming` is a programming paradigm—a style of building the structure and elements of computer programs—that `expresses the logic of a computation without describing its control flow`

This style would minimize or eliminate side effects by describing what the program must accomplish in terms of the problem domain.

Declarative programming often consider programs as theories of a formal logic, and computations as deductions in the logic space.

Common declarative languages: database query languages(SQL, XQuery), regular expressions, logic programming, functional programming, and configuration management systems.

Functional and logical programming languages are characterized by a declarative programming style. In logical programming languages, programs consist of logical statements, and the program executes by searching for proofs of the statements.

## Constraint programming

> `Constraint programming` states `relations between variables in the form of constraints` that specify the properties of the target solution. The set of constraints is solved by giving a value to each variable so that the solution is consistent with the maximum number of constraints. Constraint programming often complements other paradigms: functional, logical, or even imperative programming.

## Domain-specific languages(DSLs)

DSLs is not necessarily needing to be Turing-complete, which makes it easier for a language to be purely declarative.

## Hybrid languages

Makefiles, for example, specify dependencies in a declarative fashion, but include an imperative list of actions to take as well.

## Logic programming

> `Logic programming` languages such as Prolog state and query relations. The specifics of how these queries are answered is up to the implementation and its theorem prover, but typically take the form of some sort of unification.

Logic programming languages permit side effects, and as a result are not strictly declarative.

## Modeling

> Models, or mathematical representations, of physical systems may be implemented in computer code that is declarative. The code contains a number of equations, not imperative assignments, that describe ("declare") the behavioral relationships. When a model is expressed in this formalism, a computer is able to perform algebraic manipulations to best formulate the solution algorithm. The mathematical causality is typically imposed at the boundaries of the physical system, while the behavioral description of the system itself is declarative or acausal.

#### Reference

- <https://en.wikipedia.org/wiki/Declarative_programming>
- <https://en.wikipedia.org/wiki/Imperative_programming>
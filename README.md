# The "Scales of Game Balance"

A tool to optimise character builds for table-top roleplaying games
using genetic algorithms.

## Disclaimer

This project is just for my own amusement, and to learn genetic algorithms.
Don't assume it's compatible with the actual rules of your favourite system --
my models are probably massively broken, if they even exist.

I have no affliation with Paizo, Wizards of the Coast, or any other
game publisher, and this project is not endorsed by any of them.

## Usage

    bundle exec ruby bin/evolve_characters.rb

## Development

To run tests:

    bundle exec rspec

## Roadmap:

- [ ] Build a rough simulation of stats and combat.
- [ ] Define a "genome" format for character builds.
- [ ] Build a machine-readable list of options (classes, feats, etc.) and their effects.
- [ ] Build a machine-readable list of sample adventuring situations.
- [ ] Generate random characters, run them through sample situations, and measure their success.
- [ ] Pick the best characters, and "breed" them to evolve the next, more-optimised generation.
- [ ] Iteratively improve our model of the Pathfinder rules.
- [ ] Throw more hardware at the problem to get even better optimsation.
- ...
-Profit?

# Visual Place Recognition with Probabilistic Voting

This open source MATLAB algorith presents a straightforward probabilistic visual place recognition technique which introduces a novel score based on nearest neighbor descriptor voting and demonstrate how the algorithm naturally emerges from the problem formulation. Based on the observation that the
number of votes for matching places can be evaluated using a binomial distribution model, loop closures can be detected with high precision. By casting the problem into a probabilistic framework, we not only remove the need for commonly employed heuristic parameters but also provide a powerful score
to classify matching and non-matching places.

Note that the probabilistic voting approach is not an official implementation based on binary features, while it utilizes SURF n order to be used for comparison for our research works. The authors are not responsible for any errors it may contain. **Use it at your own risk!**

## Conditions of use
Probabilistic vertex voting is distributed under the terms of the [MIT License](https://github.com/ktsintotas/Bag-of-Tracked-Words/blob/master/LICENSE).

## Related publication
The details of the algorithm are explained in the [following publication](https://ieeexplore.ieee.org/document/7989362):

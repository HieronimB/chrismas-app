use log::trace;
use std::vec::IntoIter;

#[derive(Debug)]
struct State {
    to_draw: Vec<i32>,
    not_drawn: Vec<i32>,
    drawn_result: Option<(i32, i32)>,
    to_draw_iter: IntoIter<i32>,
    not_drawn_iter: IntoIter<i32>,
}

pub struct BacktrackingAlgorithm {
    to_draw: Vec<i32>,
    not_drawn: Vec<i32>,
    drawn_excluded: Vec<(i32, i32)>,
}

impl BacktrackingAlgorithm {
    pub fn new(
        to_draw: Vec<i32>,
        not_drawn: Vec<i32>,
        drawn_excluded: Vec<(i32, i32)>,
    ) -> BacktrackingAlgorithm {
        BacktrackingAlgorithm {
            to_draw,
            not_drawn,
            drawn_excluded,
        }
    }

    pub fn draw(&self) -> Vec<(i32, i32)> {
        let initial_state = State {
            to_draw: self.to_draw.clone(),
            not_drawn: self.not_drawn.clone(),
            drawn_result: None,
            to_draw_iter: self.to_draw.clone().into_iter(),
            not_drawn_iter: self.not_drawn.clone().into_iter(),
        };

        let mut state_by_level = vec![initial_state];
        let mut level = 0;

        while level < self.to_draw.len() {
            trace!("Start level: {:?}", level);
            let mut current_state = &mut state_by_level[level];
            trace!("Current state: {:?}", current_state);

            while let Some(to_draw) = current_state.to_draw_iter.next() {
                trace!("To draw: {:?}", to_draw);
                current_state.not_drawn_iter = current_state.not_drawn.clone().into_iter();
                current_state.drawn_result = None;

                while let Some(not_drawn) = current_state.not_drawn_iter.next() {
                    trace!("Not drawn: {:?}", not_drawn);
                    if !self.drawn_excluded.contains(&(to_draw, not_drawn)) {
                        trace!("Found him");
                        current_state.drawn_result = Some((to_draw, not_drawn));
                        trace!("Current state: {:?}", current_state);
                        break;
                    }
                }

                if current_state.drawn_result.is_some() {
                    trace!("Found, break outer loop");
                    break;
                }
            }

            if current_state.drawn_result.is_some() {
                trace!("Found, go to next level");
                let next_to_draw: Vec<i32> = current_state
                    .to_draw
                    .clone()
                    .into_iter()
                    .filter(|f| *f != current_state.drawn_result.unwrap().0)
                    .collect();

                let next_not_drawn: Vec<i32> = current_state
                    .not_drawn
                    .clone()
                    .into_iter()
                    .filter(|f| *f != current_state.drawn_result.unwrap().1)
                    .collect();

                let next_state = State {
                    to_draw: next_to_draw.clone(),
                    not_drawn: next_not_drawn.clone(),
                    drawn_result: None,
                    to_draw_iter: next_to_draw.into_iter(),
                    not_drawn_iter: next_not_drawn.into_iter(),
                };

                trace!("Next state: {:?}", next_state);
                state_by_level.push(next_state);
                level += 1;
            } else if current_state.drawn_result.is_none() && level > 0 {
                trace!("Go back");
                state_by_level.pop();
                level -= 1;
            } else {
                break;
            }
        }

        let result: Vec<(i32, i32)> = state_by_level
            .iter()
            .filter(|s| s.drawn_result.is_some())
            .map(|s| s.drawn_result.unwrap())
            .collect();
        trace!("Final: {:?}", result);
        result
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn should_be_able_to_draw_in_basic_example() {
        let mut bta = BacktrackingAlgorithm {
            to_draw: vec![1, 2, 3, 4, 5],
            not_drawn: vec![5, 4, 3, 2, 1],
            drawn_excluded: vec![
                (1, 2),
                (2, 1),
                (3, 4),
                (4, 3),
                (1, 1),
                (2, 2),
                (3, 3),
                (4, 4),
                (5, 5),
            ],
        };

        let result = bta.draw();
        assert_eq!(result.len(), 5);
    }

    #[test]
    fn should_be_able_to_draw_with_one() {
        let mut bta = BacktrackingAlgorithm {
            to_draw: vec![1],
            not_drawn: vec![1],
            drawn_excluded: vec![],
        };

        let result = bta.draw();
        assert_eq!(result[0], (1, 1));
    }

    #[test]
    fn should_be_able_to_draw_when_there_is_no_first_solution() {
        let mut bta = BacktrackingAlgorithm {
            to_draw: vec![1, 2, 3, 4],
            not_drawn: vec![1, 2, 3, 4],
            drawn_excluded: vec![(1, 1), (2, 2), (3, 3), (4, 4), (4, 1), (4, 3)],
        };

        let result = bta.draw();
        assert_eq!(result.len(), 4);
    }

    #[test]
    fn should_return_empty_when_there_is_no_solution() {
        let mut bta = BacktrackingAlgorithm {
            to_draw: vec![1],
            not_drawn: vec![1],
            drawn_excluded: vec![(1, 1)],
        };

        let result = bta.draw();
        assert_eq!(result.is_empty(), true);
    }

    #[test]
    fn should_return_partial_solution() {
        let mut bta = BacktrackingAlgorithm {
            to_draw: vec![1, 2, 3],
            not_drawn: vec![1, 2, 3],
            drawn_excluded: vec![(1, 1), (2, 2), (3, 3), (3, 1), (3, 2)],
        };

        let result = bta.draw();
        assert_eq!(result.len() < 3, true);
    }
}

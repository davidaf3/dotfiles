use anyhow::Result;
use itertools::Itertools;
use std::cmp::min;
use xshell::{Shell, cmd};

pub struct DMenuOption<T> {
    label: String,
    value: T,
}

impl<T> DMenuOption<T> {
    pub fn new(label: &str, value: T) -> Self {
        Self {
            label: label.into(),
            value,
        }
    }
}

pub struct DMenu<T> {
    prompt: String,
    options: Vec<DMenuOption<T>>,
}

impl<T> DMenu<T> {
    pub fn show(self) -> Result<Option<T>> {
        let sh = Shell::new()?;

        let lines = min(self.options.len(), 15).to_string();
        let prompt = &self.prompt;
        let selection = cmd!(sh, "fuzzel --dmenu -p {prompt} -l {lines}")
            .stdin(self.options.iter().map(|o| &o.label).join("\n"))
            .read()?;

        Ok(self
            .options
            .into_iter()
            .find(|o| o.label == selection)
            .map(|o| o.value))
    }

    pub fn new(prompt: String, options: Vec<DMenuOption<T>>) -> Self {
        Self { prompt, options }
    }

    pub fn builder() -> DMenuBuilder<T> {
        DMenuBuilder::new()
    }
}

pub struct DMenuBuilder<T> {
    prompt: String,
    options: Vec<DMenuOption<T>>,
}

impl<T> DMenuBuilder<T> {
    pub fn prompt(mut self, prompt: &str) -> Self {
        self.prompt = prompt.into();
        self
    }

    pub fn option(mut self, label: &str, value: T) -> Self {
        self.options.push(DMenuOption::new(label, value));
        self
    }

    pub fn build(self) -> DMenu<T> {
        DMenu::new(self.prompt, self.options)
    }

    pub fn new() -> Self {
        Self {
            prompt: "> ".into(),
            options: Vec::new(),
        }
    }
}

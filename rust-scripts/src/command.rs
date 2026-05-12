use anyhow::Result;
use xshell::{Shell, cmd};

#[derive(Clone)]
pub struct Command {
    program: String,
    args: Vec<String>,
}

impl Command {
    pub fn run(&self) -> Result<()> {
        let sh = Shell::new()?;
        let (program, args) = (&self.program, &self.args);
        cmd!(sh, "{program} {args...}").run()?;
        Ok(())
    }

    pub fn new(program: &str, args: &[&str]) -> Self {
        Self {
            program: program.into(),
            args: args.iter().map(|a| a.to_string()).collect(),
        }
    }
}

# Python with uv

uv is part of the baseline (`brew install uv` for an existing machine).
Homebrew's Python can remain for tools that depend on it.

For a new Python project:

```sh
uv init my-project
cd my-project
uv python pin 3.14
uv add <dependency>
uv run python main.py
```

Choose the Python version supported by the project's dependencies; 3.14 is an
example, not a requirement. `uv python pin` records `.python-version`.
Commit `pyproject.toml`, `.python-version`, and `uv.lock`; ignore `.venv/`.
For an existing uv project, use `uv sync --locked`, then `uv run ...`.
Use `uv tool install <tool>` for standalone Python command-line applications.
No Python runtime or project environment is created just by installing uv.

Reference: https://docs.astral.sh/uv/guides/projects/

The Vim debugger setup also installs the newest stable Python through uv into an
isolated `~/.local/share/developer-debugger` environment, rebuilt on each run. This does not choose runtimes
for your Python application projects.

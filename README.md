# UI Landing Page Generator

A powerful pipeline that combines **Gemini CLI** and **Claude Code** to generate distinctive, production-grade landing pages with high design quality.

## Overview

This tool generates beautiful, one-page landing pages by:

1. **Analyzing context** (PRD, brief, requirements) via Claude to craft a tailored design prompt
2. **Generating the landing page** via Gemini CLI with the crafted prompt
3. **Reviewing and improving** the code via Claude using frontend-design skill guidelines
4. **Opening the result** in your browser

The pipeline avoids generic "AI aesthetics" by using sophisticated design prompts that emphasize feeling, atmosphere, and distinctive visual choices.

## Installation

### Prerequisites

- [Gemini CLI](https://github.com/google-gemini/gemini-cli) - `npm install -g @google/gemini-cli`
- [Claude Code](https://github.com/anthropics/claude-code) - `npm install -g @anthropic-ai/claude-code`

> **Note**: Ensure both CLIs are authenticated and working before running the pipeline.

### Setup

```bash
# Clone or download this repository
git clone https://github.com/felix-huber/ui-landingpage-generator-skill.git
cd ui-landingpage-generator-skill

# Make the script executable
chmod +x generate_landing.sh
```

### Installing as a Claude Code Skill

To use this as a Claude Code skill:

```bash
# Clone to your Claude Code skills directory
git clone https://github.com/felix-huber/ui-landingpage-generator-skill ~/.claude/skills/ui-landingpage-generator
```

Or for project-local installation, clone into your project and add to `.claude/settings.json`:

```json
{
  "skills": ["./ui-landingpage-generator"]
}
```

## Usage

### Command Line

```bash
# Default mode - random design style
./generate_landing.sh

# Custom output directory
./generate_landing.sh -o my_output

# Use a custom prompt file
./generate_landing.sh -p my_prompt.txt

# Context mode - generate prompt from PRD/brief (recommended)
./generate_landing.sh -c path/to/prd.md

# Context mode with custom output
./generate_landing.sh -c requirements.md -o landing_output
```

### Options

| Option | Description |
|--------|-------------|
| `-o, --output <dir>` | Output directory (default: `result`) |
| `-p, --prompt <file>` | Use a custom prompt file |
| `-c, --context <file>` | Use context file (PRD, brief, etc.) to generate a tailored prompt via Claude |
| `-h, --help` | Show help message |

### As a Claude Code Skill

When installed as a skill, you can invoke it directly in Claude Code:

```
Generate a landing page for my project using the PRD at artifacts/01-prd.md
```

Claude will automatically use the skill to run the pipeline.

## How It Works

### Design Style Library

The generator supports 25+ design styles including:

| Category | Styles |
|----------|--------|
| **Bold & Confrontational** | Neobrutalist, Brutalist/Raw, Industrial |
| **Systematic & Clean** | Swiss/International, Modernist, Corporate Professional |
| **Warm & Human** | Scandinavian, Japandi, Organic/Fluid |
| **Luxurious & Refined** | Art Deco, Luxury Minimal, Editorial |
| **Futuristic & Technical** | Retro-futuristic, Tech Forward, Dark Mode First |
| **Playful & Dynamic** | Kinetic, Glassmorphism, Gradient Modern |
| **Artistic & Expressive** | Bauhaus, Neo-Geo, Typography First |

### Context Mode (Recommended)

When you provide a PRD or brief via `-c`, Claude analyzes:

- **Target users** - Who they are, what they value
- **Emotional journey** - What the landing page should make visitors feel
- **Brand positioning** - How to differentiate visually
- **Industry conventions** - Whether to align or deliberately contrast

Then generates a tailored three-paragraph design prompt focusing on:

1. **Vision & Atmosphere** - Mood, visual hierarchy, color guidance
2. **Typography, Motion & Narrative** - Font feel, interaction style, emotional arc
3. **Abstract Inspirations** - Architectural, cultural, and design philosophy references

### Frontend Design Guidelines

The Claude review step applies these principles:

- **Typography**: Distinctive fonts only - no Inter, Roboto, or Arial
- **Color**: Dominant colors with sharp accents, not timid palettes
- **Motion**: High-impact orchestrated animations, not scattered micro-interactions
- **Space**: Intentional whitespace or controlled density
- **Details**: Gradient meshes, noise textures, geometric patterns, dramatic shadows

## Output Files

Each run generates:

```
result/
├── generated_prompt_*.txt      # Claude-generated design prompt (context mode)
├── gemini_raw_*.txt            # Raw Gemini CLI output
├── landing_gemini_*.html       # Original Gemini-generated HTML
├── claude_raw_*.txt            # Claude review output
├── landing_reviewed_*.html     # Final reviewed HTML
└── latest.html                 # Symlink to latest result
```

## Examples

### Example 1: Random Style

```bash
./generate_landing.sh -o examples/random
```

Gemini randomly selects a style (e.g., Retro-futuristic) and generates a landing page for a fictional service.

### Example 2: From PRD

```bash
./generate_landing.sh -c ~/projects/my-app/PRD.md -o examples/my-app
```

Claude analyzes your PRD, selects an appropriate style (e.g., Swiss/International for a developer tool), and generates a landing page that matches your product's essence.

### Example 3: Custom Prompt

```bash
cat > my_prompt.txt << 'EOF'
Create a Bauhaus-inspired landing page for a geometric art gallery...
EOF

./generate_landing.sh -p my_prompt.txt -o examples/gallery
```

## Troubleshooting

### "No HTML file was generated by Gemini"

Gemini may write files to subdirectories. The script searches up to 2 levels deep. Check:
- `./result/` directory
- Any `*.html` files in the current directory

### "Claude did not return valid HTML"

The script falls back to Gemini's output. Check `claude_raw_*.txt` for errors.

### Browser doesn't open

The script supports macOS (`open`), Linux (`xdg-open`), and Windows (`start`). If none work, open the file manually:

```bash
open result/latest.html  # macOS
xdg-open result/latest.html  # Linux
```

## Requirements

- **Node.js** 18+
- **Gemini CLI** with valid credentials
- **Claude Code** with valid API access
- **macOS/Linux/Windows** (cross-platform)

## Credits

This tool combines:
- [Gemini CLI](https://github.com/google-gemini/gemini-cli) by Google
- [Claude Code](https://github.com/anthropics/claude-code) by Anthropic
- Frontend Design Skill guidelines from [Anthropic's Claude Code plugins](https://github.com/anthropics/claude-code/tree/main/plugins/frontend-design)

## License

MIT License - See LICENSE file for details.

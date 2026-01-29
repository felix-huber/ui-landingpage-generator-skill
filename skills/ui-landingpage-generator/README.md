# UI Landing Page Generator Skill

A Claude Code skill that generates distinctive, production-grade landing pages by combining Gemini CLI generation with Claude Code review.

## Features

- **Context-Aware Design**: Analyzes PRDs, briefs, and requirements to select the perfect design style
- **25+ Design Styles**: From Swiss/International to Retro-futuristic, Bauhaus to Glassmorphism
- **Dual-AI Pipeline**: Gemini generates, Claude reviews and improves
- **Production-Ready Output**: Clean HTML/CSS/JS with distinctive typography, color, and motion

## Installation

### Option 1: Global Installation

```bash
# Copy to your Claude Code skills directory
mkdir -p ~/.claude/skills
cp -r . ~/.claude/skills/ui-landingpage-generator
```

### Option 2: Project-Local Installation

Add to your project's `.claude/settings.json`:

```json
{
  "skills": ["./skills/ui-landingpage-generator"]
}
```

## Usage

Once installed, Claude Code will automatically use this skill when you ask for landing pages:

```
"Create a landing page for my project using the PRD at docs/prd.md"

"Generate a landing page with a minimalist Scandinavian design"

"I need a marketing page for my SaaS product"
```

## Requirements

- **Gemini CLI**: `npm install -g @google/gemini-cli`
- **Claude Code**: `npm install -g @anthropic-ai/claude-code`
- **Bash**: macOS, Linux, or Windows WSL

Both CLIs must be authenticated before use.

## How It Works

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Context   │────▶│   Claude    │────▶│   Gemini    │────▶│   Claude    │
│  (PRD/Brief)│     │  (Prompt)   │     │ (Generate)  │     │  (Review)   │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
                           │                   │                   │
                           ▼                   ▼                   ▼
                    Design Prompt         Raw HTML          Polished HTML
                    (3 paragraphs)        (initial)           (final)
```

## Design Philosophy

This skill enforces high design standards:

- **No Generic Fonts**: Inter, Roboto, Arial are forbidden
- **Bold Color Choices**: Dominant colors with sharp accents
- **Intentional Motion**: Orchestrated animations, not scattered effects
- **Atmospheric Depth**: Textures, gradients, and layered transparencies

## Example Output

The skill generates complete, self-contained HTML files with:

- Embedded CSS (no external dependencies)
- Responsive design
- Smooth animations
- Distinctive typography via Google Fonts
- Cross-browser compatibility

## Credits

Built on:
- [Gemini CLI](https://github.com/google-gemini/gemini-cli)
- [Claude Code](https://github.com/anthropics/claude-code)
- [Frontend Design Skill](https://github.com/anthropics/claude-code/tree/main/plugins/frontend-design)

## License

MIT

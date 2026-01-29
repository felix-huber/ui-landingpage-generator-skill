---
name: ui-landingpage-generator
description: Generate distinctive, production-grade landing pages by combining Gemini CLI generation with Claude Code review. Use this skill when the user wants to create a landing page from a PRD, brief, or design requirements. Produces polished HTML/CSS/JS with high design quality.
license: MIT
---

This skill orchestrates a pipeline to generate distinctive, production-grade landing pages that avoid generic "AI aesthetics." It combines Gemini CLI for initial generation with Claude Code for intelligent review and improvement.

## When to Use This Skill

Use this skill when the user:
- Wants to create a landing page for their product or service
- Has a PRD, brief, or requirements document they want visualized
- Asks for a "landing page," "marketing page," or "product page"
- Wants to test different design styles for their project

## How It Works

The skill runs a shell script pipeline (`generate_landing.sh`) that:

1. **Analyzes Context** (if provided): Claude reads the PRD/brief and crafts a tailored design prompt, selecting the most appropriate design style based on:
   - Target users and their expectations
   - Product/service positioning
   - Emotional journey the page should create
   - Industry conventions (to align or contrast)

2. **Generates Landing Page**: Gemini CLI creates the complete HTML/CSS/JS based on the design prompt

3. **Reviews and Improves**: Claude reviews the generated code for:
   - Bugs and broken functionality
   - CSS issues and accessibility problems
   - Design improvements per frontend-design guidelines
   - Typography, color, motion, and spatial composition

4. **Opens Result**: The final HTML is opened in the browser

## Running the Pipeline

### From Context (Recommended)

When the user provides a PRD, brief, or requirements:

```bash
./generate_landing.sh -c path/to/prd.md -o result
```

### Random Style

For exploration or demos without specific requirements:

```bash
./generate_landing.sh -o result
```

### Custom Prompt

When the user has specific design direction:

```bash
./generate_landing.sh -p custom_prompt.txt -o result
```

## Design Style Library

The skill supports 25+ design styles organized by aesthetic family:

**Bold & Confrontational**: Neobrutalist, Brutalist/Raw, Industrial/Utilitarian
**Systematic & Clean**: Swiss/International, Modernist, Corporate Professional, Flat, Material
**Warm & Human**: Scandinavian, Japandi, Organic/Fluid
**Luxurious & Refined**: Art Deco, Luxury Minimal, Editorial/Magazine, Monochromatic
**Futuristic & Technical**: Retro-futuristic, Tech Forward, Dark Mode First
**Playful & Dynamic**: Kinetic, Glassmorphism, Gradient Modern, Neumorphic
**Artistic & Expressive**: Bauhaus, Neo-Geo, Typography First, Metropolitan, Minimal

The context analysis automatically selects the most appropriate style, or you can specify one directly.

## Frontend Design Guidelines Applied

The Claude review step ensures:

- **Typography**: Distinctive, characterful fonts — never Inter, Roboto, Arial, or system defaults
- **Color & Theme**: Dominant colors with sharp accents; CSS variables for consistency
- **Motion**: High-impact orchestrated animations; staggered page-load reveals
- **Spatial Composition**: Intentional asymmetry, overlap, grid-breaking elements
- **Visual Details**: Gradient meshes, noise textures, geometric patterns, dramatic shadows

## Output Files

The pipeline generates:

```
result/
├── generated_prompt_*.txt      # Tailored design prompt (context mode)
├── gemini_raw_*.txt            # Raw Gemini output
├── landing_gemini_*.html       # Original generated HTML
├── claude_raw_*.txt            # Claude review output
├── landing_reviewed_*.html     # Final polished HTML
└── latest.html                 # Symlink to latest
```

## Example Invocations

**User**: "Create a landing page for my SQLite editor tool based on the PRD"
**Action**: Run `./generate_landing.sh -c artifacts/01-prd.md -o result`

**User**: "Generate a landing page with a retro-futuristic style"
**Action**: Create a custom prompt specifying retro-futuristic, then run with `-p`

**User**: "I want to see different design styles for landing pages"
**Action**: Run `./generate_landing.sh` multiple times to explore random styles

## Requirements

- Gemini CLI installed and configured
- Claude Code installed and configured
- Bash shell (macOS, Linux, or WSL)

## Troubleshooting

If Gemini doesn't generate HTML, check that it's properly authenticated and has write permissions.

If Claude review fails, the pipeline falls back to Gemini's output automatically.

The script supports cross-platform browser opening (macOS `open`, Linux `xdg-open`, Windows `start`).

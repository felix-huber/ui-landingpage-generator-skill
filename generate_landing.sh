#!/bin/bash
# Landing Page Generator with Gemini + Claude Review
# Usage: ./generate_landing.sh [options]
#
# Options:
#   -o, --output <dir>     Output directory (default: result)
#   -p, --prompt <file>    Use custom prompt file
#   -c, --context <file>   Use context file (PRD, brief, etc.) to generate prompt via Claude
#   -h, --help             Show this help message

set -e

# Colors for output (defined early for use in argument parsing)
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration defaults
OUTPUT_DIR="result"
PROMPT_FILE=""
CONTEXT_FILE=""
CUSTOM_PROMPT_SPECIFIED=false
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            if [ -z "$2" ] || [[ "$2" == -* ]]; then
                echo "Error: -o/--output requires a directory argument"
                exit 1
            fi
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -p|--prompt)
            if [ -z "$2" ] || [[ "$2" == -* ]]; then
                echo "Error: -p/--prompt requires a file argument"
                exit 1
            fi
            PROMPT_FILE="$2"
            CUSTOM_PROMPT_SPECIFIED=true
            shift 2
            ;;
        -c|--context)
            if [ -z "$2" ] || [[ "$2" == -* ]]; then
                echo "Error: -c/--context requires a file argument"
                exit 1
            fi
            CONTEXT_FILE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: ./generate_landing.sh [options]"
            echo ""
            echo "Options:"
            echo "  -o, --output <dir>     Output directory (default: result)"
            echo "  -p, --prompt <file>    Use custom prompt file"
            echo "  -c, --context <file>   Use context file (PRD, brief, etc.) to generate prompt via Claude"
            echo "  -h, --help             Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./generate_landing.sh                          # Use default prompt"
            echo "  ./generate_landing.sh -p my_prompt.txt         # Use custom prompt"
            echo "  ./generate_landing.sh -c prd.md                # Generate prompt from PRD context"
            echo "  ./generate_landing.sh -c brief.txt -o output   # Context mode with custom output dir"
            exit 0
            ;;
        *)
            # Legacy: first positional arg is output dir
            OUTPUT_DIR="$1"
            shift
            ;;
    esac
done

# Check for conflicting options
if [ -n "$PROMPT_FILE" ] && [ -n "$CONTEXT_FILE" ]; then
    echo -e "${YELLOW}Warning: Both -p and -c specified. Context mode (-c) will generate a new prompt, ignoring -p.${NC}"
    PROMPT_FILE=""
    CUSTOM_PROMPT_SPECIFIED=false
fi

# Default prompt file if not specified
if [ -z "$PROMPT_FILE" ] && [ -z "$CONTEXT_FILE" ]; then
    PROMPT_FILE="design_prompt.txt"
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Landing Page Generator - Gemini + Claude Review Pipeline${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Check for required tools
check_tool() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}Error: $1 is not installed${NC}"
        exit 1
    fi
}

check_tool gemini
check_tool claude

# Determine total steps based on mode
if [ -n "$CONTEXT_FILE" ]; then
    TOTAL_STEPS=5
    STEP_OFFSET=1
else
    TOTAL_STEPS=4
    STEP_OFFSET=0
fi

# Step 0: If context file provided, generate prompt via Claude
if [ -n "$CONTEXT_FILE" ]; then
    if [ ! -f "$CONTEXT_FILE" ]; then
        echo -e "${RED}Error: Context file not found: $CONTEXT_FILE${NC}"
        exit 1
    fi

    echo -e "${GREEN}[1/${TOTAL_STEPS}] Generating design prompt from context via Claude...${NC}"
    echo -e "  Context file: ${BLUE}$CONTEXT_FILE${NC}"
    echo ""

    CONTEXT_PROMPT_FILE=$(mktemp)
    GENERATED_PROMPT_FILE="$OUTPUT_DIR/generated_prompt_${TIMESTAMP}.txt"

    # Create the prompt generation request
    cat > "$CONTEXT_PROMPT_FILE" << 'CONTEXT_PROMPT_EOF'
You are an elite design strategist and creative director. Your task: transform the provided context into a masterfully crafted design brief for a ONE-PAGE LANDING PAGE that will be unforgettable.

## Your Design Philosophy

You create distinctive, production-grade interfaces that transcend generic "AI aesthetics." Every design decision must be intentional, bold, and memorable. You understand that:

- **Typography is voice** — Fonts carry personality. Generic choices (Inter, Roboto, Arial) are forbidden. Select typefaces that speak to the soul of the brand.
- **Color is emotion** — Palettes must evoke specific feelings. Dominant colors with sharp, unexpected accents create impact. Timid, evenly-distributed palettes fail.
- **Motion is storytelling** — Animations aren't decoration; they're narrative devices. One orchestrated page-load sequence with staggered reveals creates more delight than scattered micro-interactions.
- **Space is luxury** — Whether through generous whitespace or controlled density, spatial decisions communicate value and intentionality.
- **Details are credibility** — Gradient meshes, noise textures, geometric patterns, layered transparencies, dramatic shadows — these create atmosphere and depth that distinguishes premium work.

## Complete Design Style Library

Select the style that resonates most deeply with the context's essence. Consider the target users, brand positioning, and emotional goals:

**Bold & Confrontational**
- Neobrutalist (raw, bold, confrontational with structured impact)
- Brutalist/Raw (unpolished authenticity, honest materials)
- Industrial/Utilitarian (functional beauty, exposed structure)

**Systematic & Clean**
- Swiss/International (grid-based, systematic, ultra-clean typography)
- Modernist (clean lines, functional beauty, timeless)
- Corporate Professional (trust-building, established, refined)
- Flat (no depth, solid colors, simple icons, clean)
- Material (Google-inspired, cards, subtle shadows, motion)

**Warm & Human**
- Scandinavian (hygge, natural materials, warm minimalism)
- Japandi (Japanese-Scandinavian fusion, zen meets hygge)
- Organic/Fluid (flowing shapes, natural curves, sophisticated blob forms)

**Luxurious & Refined**
- Art Deco (elegant patterns, luxury, vintage sophistication)
- Luxury Minimal (premium restraint, high-end simplicity)
- Editorial/Magazine (magazine-inspired, sophisticated typography, article-focused)
- Monochromatic (single color variations, tonal depth)

**Futuristic & Technical**
- Retro-futuristic (80s vision of the future, refined nostalgia)
- Tech Forward (innovative, clean, future-focused)
- Dark Mode First (designed for dark interfaces, high contrast elegance)

**Playful & Dynamic**
- Kinetic (motion-driven, dynamic but controlled)
- Glassmorphism (translucent layers, blurred backgrounds, depth)
- Gradient Modern (sophisticated color transitions, depth through gradients)
- Neumorphic (soft shadows, extruded elements, tactile)

**Artistic & Expressive**
- Bauhaus (geometric simplicity, primary shapes, form follows function)
- Neo-Geo (refined geometric patterns, mathematical beauty)
- Typography First (type as the hero, letterforms as design)
- Metropolitan (urban sophistication, cultural depth)
- Minimal (extreme reduction, maximum whitespace, essential only)

Or synthesize your own hybrid style that perfectly captures the context's spirit.

## Your Process

1. **Deep Context Analysis**
   - Who are the users? What do they fear, desire, and value?
   - What emotional journey should the landing page create?
   - What makes this product/service genuinely different?
   - What single impression should someone remember after leaving?
   - What industry conventions exist? Should we align or deliberately contrast?

2. **Strategic Style Selection**
   - Which aesthetic family aligns with user expectations and brand essence?
   - What style would surprise and delight while still feeling appropriate?
   - How can the design itself become a competitive advantage?
   - Consider: Would users expect polish or rawness? Warmth or precision? Playfulness or authority?

3. **Craft the Design Brief**

   Generate EXACTLY THREE PARAGRAPHS that focus intensely on FEELING and ATMOSPHERE:

   **Paragraph 1 — Vision & Atmosphere**
   State your chosen style(s). For the business/service described in context, describe the core emotional qualities and feeling this style evokes. What mood should visitors experience as they arrive? How should the visual hierarchy and flow make them feel as they scroll through this single cohesive page? Include a note to incorporate colorful elements as appropriate to enhance the design's emotional impact. Make this paragraph feel like walking into a physical space.

   **Paragraph 2 — Typography, Motion & Narrative Arc**
   Explain the design philosophy through the lens of emotion and user experience. How should typography feel — authoritative, welcoming, cutting-edge, intimate, playful? What sensation should interactions and animations create — smooth and liquid, snappy and precise, gentle and organic? Describe how the single-page journey should emotionally progress from first impression through final call-to-action, creating a complete narrative arc in one scrolling experience.

   **Paragraph 3 — Abstract Inspirations**
   Provide abstract reference points that capture this aesthetic's essence — think about the feeling of certain types of spaces, cultural movements, artistic periods, architectural styles, or design philosophies that embody this aesthetic. Reference the emotional qualities of premium experiences, sophisticated environments, or refined craftsmanship that should inspire the design. Explain how these abstract references should influence the emotional quality and visual sophistication of the final single-page design, without naming specific brands or platforms.

4. **Close with the Execution Directive**
   End with: "IMPORTANT: After reading this prompt, IMMEDIATELY produce the complete HTML/CSS/JS code for the landing page. Output the full working code that can be saved as an HTML file and opened in a browser."

## Output Requirements

The generated prompt must emphasize this is ONE COHESIVE LANDING PAGE with a single scrolling experience. Focus on feeling, atmosphere, and abstract quality references rather than technical details or specific examples. Keep all references conceptual and high-level to allow for maximum creative interpretation.

Output ONLY the three-paragraph prompt plus the closing directive. No preamble, no explanations, no markdown formatting — just elegant, evocative prose that will inspire extraordinary design work.

## Context to Transform:

CONTEXT_PROMPT_EOF

    # Append the context file
    cat "$CONTEXT_FILE" >> "$CONTEXT_PROMPT_FILE"

    # Run Claude to generate the prompt
    echo -e "  Analyzing context and generating tailored design prompt..."
    if ! cat "$CONTEXT_PROMPT_FILE" | claude --print --output-format text > "$GENERATED_PROMPT_FILE" 2>&1; then
        echo -e "${RED}Error: Claude failed to generate prompt${NC}"
        cat "$GENERATED_PROMPT_FILE"
        rm -f "$CONTEXT_PROMPT_FILE"
        exit 1
    fi

    # Clean up
    rm -f "$CONTEXT_PROMPT_FILE"

    # Validate the generated prompt is not empty
    if [ ! -s "$GENERATED_PROMPT_FILE" ]; then
        echo -e "${RED}Error: Claude returned empty output${NC}"
        exit 1
    fi

    # Use the generated prompt
    PROMPT_FILE="$GENERATED_PROMPT_FILE"

    echo -e "  ${GREEN}✓ Design prompt generated${NC}"
    echo -e "  Saved to: ${BLUE}$GENERATED_PROMPT_FILE${NC}"
    echo ""
    echo -e "${YELLOW}--- Generated Prompt Preview ---${NC}"
    head -20 "$PROMPT_FILE"
    echo -e "${YELLOW}...${NC}"
    echo ""
fi

# Validate custom prompt file exists (only if explicitly specified via -p)
if [ "$CUSTOM_PROMPT_SPECIFIED" = true ] && [ ! -f "$PROMPT_FILE" ]; then
    echo -e "${RED}Error: Prompt file not found: $PROMPT_FILE${NC}"
    exit 1
fi

# Create default prompt file if needed
if [ ! -f "$PROMPT_FILE" ]; then
    echo -e "${YELLOW}Creating default design prompt...${NC}"
    cat > "$PROMPT_FILE" << 'PROMPT_EOF'
Generate a ONE-PAGE LANDING PAGE creation prompt using a RANDOMLY SELECTED design style from the following list, or choose your own style if you identify something more suitable that's not listed. IMPORTANT: Use a random selection method - any method that ensures variety. DO NOT default to Neobrutalist or any particular favorite. Actually randomize your selection.

**Available Design Styles (not limited to these - feel free to identify and use other professional styles):**

- Neobrutalist (raw, bold, confrontational with structured impact)
- Swiss/International (grid-based, systematic, ultra-clean typography)
- Editorial (magazine-inspired, sophisticated typography, article-focused)
- Glassmorphism (translucent layers, blurred backgrounds, depth)
- Retro-futuristic (80s vision of the future, refined nostalgia)
- Bauhaus (geometric simplicity, primary shapes, form follows function)
- Art Deco (elegant patterns, luxury, vintage sophistication)
- Minimal (extreme reduction, maximum whitespace, essential only)
- Flat (no depth, solid colors, simple icons, clean)
- Material (Google-inspired, cards, subtle shadows, motion)
- Neumorphic (soft shadows, extruded elements, tactile)
- Monochromatic (single color variations, tonal depth)
- Scandinavian (hygge, natural materials, warm minimalism)
- Japandi (Japanese-Scandinavian fusion, zen meets hygge)
- Dark Mode First (designed for dark interfaces, high contrast elegance)
- Modernist (clean lines, functional beauty, timeless)
- Organic/Fluid (flowing shapes, natural curves, sophisticated blob forms)
- Corporate Professional (trust-building, established, refined)
- Tech Forward (innovative, clean, future-focused)
- Luxury Minimal (premium restraint, high-end simplicity)
- Neo-Geo (refined geometric patterns, mathematical beauty)
- Kinetic (motion-driven, dynamic but controlled)
- Gradient Modern (sophisticated color transitions, depth through gradients)
- Typography First (type as the hero, letterforms as design)
- Metropolitan (urban sophistication, cultural depth)

**Instructions:**

After selecting a design style (either from the list or your own professional choice), create a ONE-PAGE LANDING PAGE prompt that is EXACTLY THREE PARAGRAPHS. Focus intensely on conveying the FEELING and ATMOSPHERE of the chosen style:

Paragraph 1: State the chosen style(s) and ask the AI to conceive an innovative business/service concept for a SINGLE-PAGE landing page. Describe the core emotional qualities and feeling this style evokes - what mood should visitors experience as they arrive? How should the visual hierarchy and flow make them feel as they scroll through this single cohesive page? Include a note to incorporate colorful elements as appropriate to enhance the design's emotional impact.

Paragraph 2: Explain the design philosophy through the lens of emotion and user experience. How should typography feel - authoritative, welcoming, cutting-edge? What sensation should interactions and animations create - smooth and liquid, snappy and precise, gentle and organic? Describe how the single-page journey should emotionally progress from first impression through final call-to-action, creating a complete narrative arc in one scrolling experience.

Paragraph 3: Provide abstract reference points that capture this aesthetic's essence - think about the feeling of certain types of spaces, cultural movements, artistic periods, architectural styles, or design philosophies that embody this aesthetic. Reference the emotional qualities of premium experiences, sophisticated environments, or refined craftsmanship that should inspire the design. Explain how these abstract references should influence the emotional quality and visual sophistication of the final single-page design, without naming specific brands or platforms.

The generated prompt must emphasize this is ONE COHESIVE LANDING PAGE with a single scrolling experience. Focus on feeling, atmosphere, and abstract quality references rather than technical details or specific examples. Keep all references conceptual and high-level to allow for maximum creative interpretation.

IMPORTANT: After generating the 3-paragraph prompt, IMMEDIATELY execute it yourself and produce the complete HTML/CSS/JS code for the landing page. Output the full working code that can be saved as an HTML file and opened in a browser.
PROMPT_EOF
fi

# Step: Run Gemini to generate the landing page
CURRENT_STEP=$((1 + STEP_OFFSET))
echo -e "${GREEN}[${CURRENT_STEP}/${TOTAL_STEPS}] Running Gemini CLI to generate landing page...${NC}"
echo ""

GEMINI_OUTPUT="$OUTPUT_DIR/gemini_raw_${TIMESTAMP}.txt"
# Run gemini and capture output (stderr goes to terminal for progress)
gemini -y --output-format text -p "$(cat "$PROMPT_FILE")" 2>&1 | tee "$GEMINI_OUTPUT"

# Step: Find the generated HTML file
echo ""
CURRENT_STEP=$((2 + STEP_OFFSET))
echo -e "${GREEN}[${CURRENT_STEP}/${TOTAL_STEPS}] Locating generated HTML file...${NC}"

# Find the most recently modified HTML file (Gemini may create different filenames)
# Store the time before running Gemini to compare
GENERATED_HTML=""

# Check for common Gemini output patterns - most recently modified
for pattern in "index.html" "landing*.html" "*.html"; do
    CANDIDATE=$(find . -maxdepth 2 -name "$pattern" -newer "$GEMINI_OUTPUT" 2>/dev/null | head -1)
    if [ -n "$CANDIDATE" ]; then
        GENERATED_HTML="$CANDIDATE"
        break
    fi
done

# Fallback: find any HTML file modified in the last minute
if [ -z "$GENERATED_HTML" ]; then
    GENERATED_HTML=$(find . -maxdepth 2 -name "*.html" -mmin -1 2>/dev/null | head -1)
fi

if [ -z "$GENERATED_HTML" ]; then
    echo -e "${RED}Error: No HTML file was generated by Gemini${NC}"
    echo -e "${YELLOW}Tip: Check if Gemini created the file in a subdirectory${NC}"
    exit 1
fi

echo -e "  Found: ${BLUE}$GENERATED_HTML${NC}"

# Copy to output directory with timestamp
cp "$GENERATED_HTML" "$OUTPUT_DIR/landing_gemini_${TIMESTAMP}.html"

# Step: Run Claude to review and improve the code
echo ""
CURRENT_STEP=$((3 + STEP_OFFSET))
echo -e "${GREEN}[${CURRENT_STEP}/${TOTAL_STEPS}] Running Claude Code review with frontend-design skill...${NC}"
echo ""

REVIEW_OUTPUT="$OUTPUT_DIR/landing_reviewed_${TIMESTAMP}.html"
CLAUDE_PROMPT_FILE=$(mktemp)

# Create the review prompt with the skill context in a temp file
cat > "$CLAUDE_PROMPT_FILE" << 'REVIEW_EOF'
You are reviewing and improving a generated landing page using the frontend-design skill guidelines.

## Frontend Design Skill Guidelines

This skill guides creation of distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Implement real working code with exceptional attention to aesthetic details and creative choices.

### Design Thinking
Before coding, understand the context and commit to a BOLD aesthetic direction:
- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Pick an extreme: brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian, etc.
- **Differentiation**: What makes this UNFORGETTABLE? What's the one thing someone will remember?

**CRITICAL**: Choose a clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work - the key is intentionality, not intensity.

### Frontend Aesthetics Guidelines
Focus on:
- **Typography**: Choose fonts that are beautiful, unique, and interesting. Avoid generic fonts like Arial and Inter; opt instead for distinctive choices that elevate the frontend's aesthetics.
- **Color & Theme**: Commit to a cohesive aesthetic. Use CSS variables for consistency. Dominant colors with sharp accents outperform timid, evenly-distributed palettes.
- **Motion**: Use animations for effects and micro-interactions. Focus on high-impact moments: one well-orchestrated page load with staggered reveals creates more delight than scattered micro-interactions.
- **Spatial Composition**: Unexpected layouts. Asymmetry. Overlap. Diagonal flow. Grid-breaking elements. Generous negative space OR controlled density.
- **Backgrounds & Visual Details**: Create atmosphere and depth. Apply creative forms like gradient meshes, noise textures, geometric patterns, layered transparencies, dramatic shadows.

NEVER use generic AI-generated aesthetics like overused font families (Inter, Roboto, Arial, system fonts), cliched color schemes, predictable layouts, or cookie-cutter design.

## Your Task

1. Review the HTML/CSS/JS code below for:
   - Bugs, errors, or broken functionality
   - CSS issues (@import placement, conflicting styles, unused variables)
   - JavaScript errors or incomplete code
   - Broken links or missing IDs
   - Accessibility issues
   - Mobile responsiveness problems

2. Improve the design according to the frontend-design skill:
   - Enhance typography with more distinctive font choices if needed
   - Improve color harmony and contrast
   - Add or refine animations for better impact
   - Ensure the design is cohesive and memorable

3. **CRITICAL OUTPUT REQUIREMENT**: Output ONLY the complete HTML file.
   - Start your response with `<!DOCTYPE html>`
   - End your response with `</html>`
   - NO explanations, NO markdown code blocks, NO commentary
   - Just the raw HTML/CSS/JS code that can be saved directly to a .html file

## Code to Review:

REVIEW_EOF

# Append the generated HTML to the prompt file
cat "$GENERATED_HTML" >> "$CLAUDE_PROMPT_FILE"

# Run Claude with the prompt from stdin
CLAUDE_RAW_OUTPUT="$OUTPUT_DIR/claude_raw_${TIMESTAMP}.txt"
if ! cat "$CLAUDE_PROMPT_FILE" | claude --print --output-format text > "$CLAUDE_RAW_OUTPUT" 2>&1; then
    echo -e "  ${YELLOW}⚠ Claude review encountered an error, using Gemini output${NC}"
    cp "$OUTPUT_DIR/landing_gemini_${TIMESTAMP}.html" "$CLAUDE_RAW_OUTPUT"
fi

# Clean up temp file
rm -f "$CLAUDE_PROMPT_FILE"

# Check if Claude output contains valid HTML
if grep -q "<!DOCTYPE html>" "$CLAUDE_RAW_OUTPUT" || grep -q "<html" "$CLAUDE_RAW_OUTPUT"; then
    echo -e "  ${GREEN}✓ Claude review complete${NC}"

    # Extract HTML from the output
    # Try to find HTML between ```html and ``` first, then try plain ```, then raw HTML
    if grep -q '```html' "$CLAUDE_RAW_OUTPUT"; then
        # Extract content between ```html and the next ``` (handles whitespace)
        awk '/^[[:space:]]*```html/,/^[[:space:]]*```[[:space:]]*$/{if(!/```/)print}' "$CLAUDE_RAW_OUTPUT" > "$REVIEW_OUTPUT"
    elif grep -q '```' "$CLAUDE_RAW_OUTPUT"; then
        # Extract content between first ``` and next ``` (handles whitespace)
        awk '/^[[:space:]]*```[^`]*$/,/^[[:space:]]*```[[:space:]]*$/{if(!/^[[:space:]]*```/)print}' "$CLAUDE_RAW_OUTPUT" > "$REVIEW_OUTPUT"
    else
        # No code blocks, try to extract just the HTML portion
        # Find line with <!DOCTYPE or <html and take everything from there
        awk '/<!DOCTYPE html>|<html/{found=1} found{print}' "$CLAUDE_RAW_OUTPUT" > "$REVIEW_OUTPUT"
    fi

    # Verify we got valid HTML, otherwise fall back
    if [ ! -s "$REVIEW_OUTPUT" ] || ! grep -q "<html" "$REVIEW_OUTPUT"; then
        echo -e "  ${YELLOW}⚠ Could not extract HTML, using raw output${NC}"
        cp "$CLAUDE_RAW_OUTPUT" "$REVIEW_OUTPUT"
    fi
else
    echo -e "  ${YELLOW}⚠ Claude did not return valid HTML, using Gemini output${NC}"
    cp "$OUTPUT_DIR/landing_gemini_${TIMESTAMP}.html" "$REVIEW_OUTPUT"
fi

# Create a symlink to the latest version
ln -sf "landing_reviewed_${TIMESTAMP}.html" "$OUTPUT_DIR/latest.html"

# Step: Open in browser
echo ""
CURRENT_STEP=$((4 + STEP_OFFSET))
echo -e "${GREEN}[${CURRENT_STEP}/${TOTAL_STEPS}] Opening in browser...${NC}"
echo ""

# Cross-platform browser open
if command -v open &> /dev/null; then
    open "$REVIEW_OUTPUT"
elif command -v xdg-open &> /dev/null; then
    xdg-open "$REVIEW_OUTPUT"
elif command -v start &> /dev/null; then
    start "$REVIEW_OUTPUT"
else
    echo -e "  ${YELLOW}Could not auto-open browser. Open manually: ${BLUE}$REVIEW_OUTPUT${NC}"
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ Complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  Files generated:"
if [ -n "$CONTEXT_FILE" ]; then
    echo -e "    ${BLUE}$GENERATED_PROMPT_FILE${NC} - Generated design prompt (from context)"
fi
echo -e "    ${BLUE}$GEMINI_OUTPUT${NC} - Raw Gemini output"
echo -e "    ${BLUE}$OUTPUT_DIR/landing_gemini_${TIMESTAMP}.html${NC} - Gemini HTML"
echo -e "    ${BLUE}$CLAUDE_RAW_OUTPUT${NC} - Raw Claude output"
echo -e "    ${BLUE}$REVIEW_OUTPUT${NC} - Claude reviewed HTML (final)"
echo -e "    ${BLUE}$OUTPUT_DIR/latest.html${NC} - Symlink to latest"
echo ""

# Personal Website

A minimalistic Jekyll-based personal website ready for GitHub Pages.

## Quick Start

1. Install Jekyll dependencies:
   ```bash
   bundle install
   ```

2. Run the site locally:
   ```bash
   bundle exec jekyll serve
   ```

3. Visit `http://localhost:4000` in your browser

## Customization

### Essential Updates

1. **Update `_config.yml`**:
   - Change `title` to your name
   - Update `email` and `description`
   - Add your social media handles

2. **Replace profile photo**:
   - Add your photo to `assets/images/profile-placeholder.jpg`

3. **Update homepage** (`index.html`):
   - Modify the intro text in the profile section

4. **Add your writings**:
   - Create new markdown files in `_writings/` folder
   - Follow the existing file naming pattern: `YYYY-MM-DD-title.md`

### Publishing to GitHub Pages

1. Create a new repository named `[your-username].github.io`
2. Push this code to the repository
3. GitHub will automatically build and serve your site

## Structure

- `index.html` - Homepage
- `writings.html` - List of all writings
- `_writings/` - Your blog posts/articles
- `_layouts/` - Page templates
- `assets/css/` - Styling
- `_config.yml` - Site configuration
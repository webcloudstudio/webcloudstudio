/**
 * Tag Colors Configuration
 *
 * Color Palette:
 * - green:   Used for Python, backend languages (#22c55e)
 * - orange:  Used for databases, data-related (#fb923c)
 * - blue:    Used for DevOps, infrastructure, operations (#4f9cf9)
 * - purple:  Used for frontend, UI, design (#a78bfa)
 * - red:     Used for security, authentication (#f87171)
 * - slate:   Used for general, miscellaneous, best practices (#64748b)
 */

export const TAG_COLORS: Record<string, string> = {
  // Backend & Languages
  'Python': 'green',
  'Django': 'green',
  'Perl': 'green',
  'C++': 'green',
  'Node.js': 'green',
  'JavaScript': 'green',
  'TypeScript': 'green',

  // Database
  'PostgreSQL': 'orange',
  'Database': 'orange',
  'Sql': 'orange',
  'MySQL': 'orange',
  'Sybase': 'orange',
  'SQL Server': 'orange',
  'Data': 'orange',
  'Stored Procedure': 'orange',

  // DevOps & Infrastructure
  'Docker': 'blue',
  'Railway': 'blue',
  'DevOps': 'blue',
  'Kubernetes': 'blue',
  'AWS': 'blue',
  'Infrastructure': 'blue',
  'Operations': 'blue',
  'Monitoring': 'blue',
  'Server Administration': 'blue',
  'Enterprise': 'blue',

  // Frontend & UI
  'Bootstrap': 'purple',
  'React': 'purple',
  'Vue': 'purple',
  'CSS': 'purple',
  'HTML': 'purple',
  'UI': 'purple',
  'Design': 'purple',
  'Frontend': 'purple',
  'CGI': 'purple',

  // Security & Auth
  'OAuth': 'red',
  'Security': 'red',
  'Authentication': 'red',
  'Encryption': 'red',

  // General & Best Practices
  'Claude': 'slate',
  'Administration': 'slate',
  'Process': 'slate',
  'Best Practices': 'slate',
  'Agile': 'slate',
  'Game': 'slate',
  'Free': 'slate',
  'Mulit-Player': 'slate',
  'Free Software': 'slate',
};

/**
 * Get color class for a tag name
 * Returns the appropriate color class (tag--green, tag--orange, etc.)
 * or assigns a new color if not found
 */
export function getTagColorClass(tagName: string): string {
  const color = TAG_COLORS[tagName];

  if (color) {
    return `tag--${color}`;
  }

  // Auto-assign new tags to slate (default/neutral)
  return 'tag--slate';
}

/**
 * Helper to add a new tag to the configuration
 * This is for reference only - update TAG_COLORS directly above
 */
export function suggestTagColor(
  tagName: string,
  category: 'backend' | 'database' | 'devops' | 'frontend' | 'security' | 'general'
): string {
  const colorMap: Record<typeof category, string> = {
    backend: 'green',
    database: 'orange',
    devops: 'blue',
    frontend: 'purple',
    security: 'red',
    general: 'slate',
  };
  return colorMap[category];
}

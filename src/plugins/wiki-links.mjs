import { visit } from 'unist-util-visit';

const wikiLinks = () => {
  return (tree, file) => {
    visit(tree, 'text', (node, index, parent) => {
      if (!node.value) return;
      
      const wikiLinkRegex = /\[\[([^\]|]+)(?:\|([^\]]+))?\]\]/g;
      const text = node.value;
      const matches = [...text.matchAll(wikiLinkRegex)];
      
      if (matches.length === 0) return;
      
      const newNodes = [];
      let lastIndex = 0;
      
      for (const match of matches) {
        const fullMatch = match[0];
        const slug = match[2] || match[1];
        const displayText = match[2] ? match[1] : match[1];
        const matchIndex = match.index;
        
        if (matchIndex > lastIndex) {
          newNodes.push({
            type: 'text',
            value: text.slice(lastIndex, matchIndex)
          });
        }
        
        newNodes.push({
          type: 'link',
          url: `/blog/${slug.toLowerCase().replace(/\s+/g, '-')}/`,
          children: [{ type: 'text', value: displayText }],
          data: {
            hProperties: {
              className: ['wiki-link']
            }
          }
        });
        
        lastIndex = matchIndex + fullMatch.length;
      }
      
      if (lastIndex < text.length) {
        newNodes.push({
          type: 'text',
          value: text.slice(lastIndex)
        });
      }
      
      if (newNodes.length > 0) {
        parent.children.splice(index, 1, ...newNodes);
      }
    });
  };
};

export default wikiLinks;
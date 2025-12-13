---
name: AWS Documentation MCP Skill
description: This skill provides comprehensive guidance on using the three AWS Documentation MCP tools to effectively browse, search, and learn from AWS documentation. The tools enable LLMs to access up-to-date AWS documentation in a structured, efficient manner.
---

## Execution

All JavaScript code examples in this document should be executed using:
```bash
bun -cwd ~/.claude/skills/jun_cli -e "<code>"
```

Simply paste the JavaScript code (without the import statement) into the template above.

## Tool Reference

- **aws_docs_mcp--search_documentation**: Searches AWS docs with query and limit parameters
- **aws_docs_mcp--read_documentation**: Fetches AWS pages as markdown with pagination support
- **aws_docs_mcp--recommend**: Gets content recommendations based on a URL

## Best Practices

### Search Guidelines
1. **Be Specific**: Use technical terms rather than general phrases
   - Good: "S3 bucket versioning configuration"
   - Poor: "versioning"

2. **Include Service Names**: Narrow results by including the AWS service
   - Good: "Lambda function URLs"
   - Poor: "function URLs"

3. **Use Quotes**: For exact phrase matching
   - Example: "AWS Lambda function URLs"

4. **Set Appropriate Limits**: Use smaller limits for focused searches, larger for comprehensive research

### Reading Documentation
1. **Check for Truncation**: Always look for `<e>Content truncated` indicator
2. **Use Pagination**: For long documents, incrementally read using start_index
3. **Default Settings Work**: The default max_length (5000) is suitable for most use cases
4. **URL Requirements**: Must be from docs.aws.amazon.com domain and end with .html

### Using Recommendations
1. **Discover New Features**: Look for recommendations with "New content added" timestamps
2. **Explore Services**: Use recommend after reading any page to find related content
3. **Welcome Pages**: Use service welcome pages to get comprehensive recommendations

## Common Workflows

### Workflow 1: Learning a New AWS Service
```
1. search_documentation("What is [ServiceName]")
2. read_documentation(URL from top result)
3. recommend(URL you just read)
4. Explore recommendations for practical examples
```

**Example: Learning AWS Lambda**
```javascript
// Import for reference only - do not include when executing with bun
// import { search_documentation, read_documentation, recommend } from './tools/aws_docs_mcp';

// Step 1: Search for Lambda overview
const searchResults = await search_documentation({
  search_phrase: "What is AWS Lambda",
  limit: 5
});

// Step 2: Read the main overview
const overview = await read_documentation({
  url: searchResults.search_results[0].url
});

// Step 3: Get recommendations
const recommendations = await recommend({
  url: searchResults.search_results[0].url
});
```

### Workflow 2: Finding Solution to Specific Problem
```
1. search_documentation with specific problem terms
2. Review search results based on context snippets
3. read_documentation for most relevant result
4. recommend to find related configuration topics
```

**Example: Setting up S3 Cross-Region Replication**
```javascript
// Import for reference only - do not include when executing with bun
// import { search_documentation, read_documentation, recommend } from './tools/aws_docs_mcp';

// Step 1: Search for specific solution
const searchResults = await search_documentation({
  search_phrase: "S3 cross-region replication setup",
  limit: 10
});

// Step 2: Read the setup guide
const setupGuide = await read_documentation({
  url: "https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication.html"
});

// Step 3: Find related topics
const related = await recommend({
  url: "https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication.html"
});
```

### Workflow 3: Discovering New Features
```
1. Find any page of the service (welcome page works best)
2. recommend the page URL
3. Look for "New content added on" timestamps
4. Read documentation about new features
```

**Example: Finding New Lambda Features**
```javascript
// Import for reference only - do not include when executing with bun
// import { recommend, read_documentation } from './tools/aws_docs_mcp';

// Step 1: Use Lambda welcome page
const recommendations = await recommend({
  url: "https://docs.aws.amazon.com/lambda/latest/dg/welcome.html"
});

// Step 2: Filter for new content
const newFeatures = recommendations.result.filter(rec =>
  rec.context.includes("New content added")
);

// Step 3: Read about new features
for (const feature of newFeatures) {
  const details = await read_documentation({
    url: feature.url,
    max_length: 3000
  });
  // Process the feature details
}
```

### Workflow 4: Deep Dive into Complex Topic
```
1. search_documentation for comprehensive topic
2. read_documentation (may require multiple calls with pagination)
3. recommend to find additional perspectives
4. search_documentation for complementary topics
```

**Example: Understanding Lambda Performance**
```javascript
// Import for reference only - do not include when executing with bun
// import { search_documentation, read_documentation, recommend } from './tools/aws_docs_mcp';

// Step 1: Search for performance optimization
const searchResults = await search_documentation({
  search_phrase: "Lambda cold start optimization",
  limit: 15
});

// Step 2: Read comprehensive guide
const guide = await read_documentation({
  url: searchResults.search_results[0].url,
  max_length: 8000
});

// Step 3: Get related perspectives
const related = await recommend({
  url: searchResults.search_results[0].url
});

// Step 4: Search for complementary topics
const complementary = await search_documentation({
  search_phrase: "Lambda provisioned concurrency",
  limit: 5
});
```

### Workflow 5: Troubleshooting
```
1. search_documentation with error-specific terms
2. read_documentation for troubleshooting guides
3. recommend to find best practices
4. search for alternative approaches if needed
```

**Example: Debugging Lambda Timeouts**
```javascript
// Import for reference only - do not include when executing with bun
// import { search_documentation, read_documentation, recommend } from './tools/aws_docs_mcp';

// Step 1: Search for timeout issues
const searchResults = await search_documentation({
  search_phrase: "Lambda timeout errors debugging",
  limit: 10
});

// Step 2: Read troubleshooting guide
const troubleshooting = await read_documentation({
  url: searchResults.search_results.find(r =>
    r.title.includes("troubleshooting")
  ).url
});

// Step 3: Find best practices
const bestPractices = await recommend({
  url: searchResults.search_results[0].url
});
```

## Error Handling

The tools provide clear error messages for common issues:

### Validation Errors
- `max_length` must be less than 1,000,000
- URLs must be from docs.aws.amazon.com and end with .html
- `limit` must be between 1 and 50

### Handling Truncated Content
When content is truncated:
```javascript
// Import for reference only - do not include when executing with bun
// import { read_documentation } from './tools/aws_docs_mcp';

let allContent = "";
let startIndex = 0;
let hasMore = true;

while (hasMore) {
  const result = await read_documentation({
    url: documentUrl,
    start_index: startIndex,
    max_length: 5000
  });

  allContent += result.result;
  hasMore = result.result.includes("<e>Content truncated");
  startIndex += 5000;
}
```

## Limitations

### read_documentation
- URL restrictions: Only docs.aws.amazon.com domain, must end with .html
- Content truncation: Large documents require pagination
- Maximum length: 999,999 characters per request

### search_documentation
- Result limit: Maximum 50 results per query
- Index freshness: Depends on AWS search index update frequency
- Legacy content: May include documentation for deprecated features

### recommend
- Pattern-based: Recommendations based on general usage patterns
- Volume: Number of recommendations varies (typically 20-40)
- Niche topics: May not cover highly specialized or edge cases

## Advanced Patterns

### Pattern 1: Building a Knowledge Base
```javascript
// Import for reference only - do not include when executing with bun
// import { search_documentation, read_documentation, recommend } from './tools/aws_docs_mcp';

async function buildServiceKnowledgeBase(serviceName) {
  const knowledge = {
    overview: {},
    features: [],
    bestPractices: [],
    troubleshooting: [],
    newFeatures: []
  };

  // Get overview
  const overviewResults = await search_documentation({
    search_phrase: `What is ${serviceName}`,
    limit: 3
  });

  if (overviewResults.search_results.length > 0) {
    knowledge.overview = await read_documentation({
      url: overviewResults.search_results[0].url
    });

    // Get comprehensive recommendations
    const recommendations = await recommend({
      url: overviewResults.search_results[0].url
    });

    // Categorize recommendations
    recommendations.result.forEach(rec => {
      if (rec.context.includes("New content added")) {
        knowledge.newFeatures.push(rec);
      } else if (rec.title.toLowerCase().includes("best practice")) {
        knowledge.bestPractices.push(rec);
      } else if (rec.title.toLowerCase().includes("troubleshoot")) {
        knowledge.troubleshooting.push(rec);
      } else {
        knowledge.features.push(rec);
      }
    });
  }

  return knowledge;
}
```

### Pattern 2: Comparative Analysis
```javascript
// Import for reference only - do not include when executing with bun
// import { search_documentation } from './tools/aws_docs_mcp';

async function compareFeatures(feature, services) {
  const comparison = {};

  for (const service of services) {
    const results = await search_documentation({
      search_phrase: `${service} ${feature}`,
      limit: 3
    });

    if (results.search_results.length > 0) {
      comparison[service] = {
        url: results.search_results[0].url,
        title: results.search_results[0].title,
        summary: results.search_results[0].context
      };
    }
  }

  return comparison;
}
```

## Conclusion

The AWS Documentation MCP tools provide powerful capabilities for accessing AWS documentation programmatically. By following the best practices and workflows outlined in this skill, you can effectively leverage these tools to:

1. Learn new AWS services quickly
2. Solve specific problems with accurate information
3. Stay updated with new features
4. Perform deep research on complex topics
5. Troubleshoot issues efficiently

The tools are designed to work together, enabling sophisticated documentation exploration and knowledge discovery workflows.
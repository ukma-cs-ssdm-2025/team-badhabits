const http = require('http');
const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

const app = require('../app');

const PORT = 3000;
const API_DOCS_URL = `http://localhost:${PORT}/api-docs-json`;
const OUTPUT_PATH = path.join(__dirname, '../../../docs/api/openapi-generated.yaml');

let server;


function fetchOpenAPISpec() {
  return new Promise((resolve, reject) => {
    http.get(API_DOCS_URL, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        if (res.statusCode === 200) {
          try {
            const jsonSpec = JSON.parse(data);
            resolve(jsonSpec);
          } catch (error) {
            reject(new Error(`Failed to parse JSON: ${error.message}`));
          }
        } else {
          reject(new Error(`HTTP ${res.statusCode}: ${data}`));
        }
      });
    }).on('error', (error) => {
      reject(new Error(`Request failed: ${error.message}`));
    });
  });
}

function saveAsYAML(jsonSpec, outputPath) {
  try {
    const yamlContent = yaml.dump(jsonSpec, {
      indent: 2,
      lineWidth: 120,
      noRefs: true,
    });

    const dir = path.dirname(outputPath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    fs.writeFileSync(outputPath, yamlContent, 'utf8');
    console.log(`OpenAPI specification saved to: ${outputPath}`);
  } catch (error) {
    throw new Error(`Failed to save YAML: ${error.message}`);
  }
}

async function generateOpenAPI() {
  console.log('🚀 Starting OpenAPI generation process...\n');

  try {
    console.log(`Starting server on port ${PORT}...`);
    server = app.listen(PORT, () => {
      console.log(`Server started on http://localhost:${PORT}`);
    });

    console.log('⏳ Waiting 2 seconds for server to initialize...');
    await new Promise((resolve) => setTimeout(resolve, 2000));

    console.log(`Fetching OpenAPI spec from ${API_DOCS_URL}...`);
    const openAPISpec = await fetchOpenAPISpec();
    console.log(`OpenAPI spec fetched successfully (${Object.keys(openAPISpec.paths || {}).length} endpoints)`);

    console.log(`Converting to YAML and saving to ${OUTPUT_PATH}...`);
    saveAsYAML(openAPISpec, OUTPUT_PATH);

    console.log('\n OpenAPI generation completed successfully!');
    console.log(`\n Generated file: ${OUTPUT_PATH}`);
    console.log(`Total endpoints: ${Object.keys(openAPISpec.paths || {}).length}`);
    console.log(`Components schemas: ${Object.keys(openAPISpec.components?.schemas || {}).length}`);

  } catch (error) {
    console.error('\n Error during OpenAPI generation:');
    console.error(error.message);
    process.exit(1);
  } finally {
    if (server) {
      console.log('\n Shutting down server...');
      server.close(() => {
        console.log('Server shut down successfully');
        process.exit(0);
      });

      setTimeout(() => {
        console.log('Forcing server shutdown...');
        process.exit(0);
      }, 5000);
    }
  }
}

generateOpenAPI();

// ESLint Configuration for Wellity Backend (Node.js)
// Using ESLint v9+ flat config format
// Based on OWASP security principles and Google Style Guide

import js from '@eslint/js';
import globals from 'globals';

export default [
  // Ignore patterns
  {
    ignores: [
      'node_modules/**',
      'coverage/**',
      'dist/**',
      'build/**',
      '*.min.js',
    ],
  },

  // Base configuration for all JS files
  {
    files: ['**/*.js'],
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: {
        ...globals.node,
        ...globals.es2021,
      },
    },
    rules: {
      // Extend recommended rules
      ...js.configs.recommended.rules,

      // ===== SECURITY RULES (OWASP Principles) =====
      // Critical security issues that must be prevented
      'no-eval': 'error',
      'no-implied-eval': 'error',
      'no-new-func': 'error',
      'no-script-url': 'error',
      'no-with': 'error',

      // Prevent potential security vulnerabilities
      'no-caller': 'error',
      'no-extend-native': 'error',
      'no-proto': 'error',

      // ===== ERROR HANDLING (Critical for production) =====
      'no-throw-literal': 'error',
      'prefer-promise-reject-errors': 'error',
      'no-async-promise-executor': 'error',
      'require-atomic-updates': 'error',

      // ===== CODE QUALITY AND MAINTAINABILITY =====
      'no-unused-vars': ['error', {
        vars: 'all',
        args: 'after-used',
        ignoreRestSiblings: true,
        argsIgnorePattern: '^_',
      }],
      'no-undef': 'error',
      'no-unreachable': 'error',
      'no-constant-condition': 'error',
      'no-dupe-keys': 'error',
      'no-duplicate-case': 'error',
      'no-empty': ['error', { allowEmptyCatch: false }],
      'no-ex-assign': 'error',
      'no-extra-boolean-cast': 'error',
      'no-func-assign': 'error',
      'no-irregular-whitespace': 'error',
      'no-sparse-arrays': 'error',
      'use-isnan': 'error',
      'valid-typeof': 'error',

      // ===== BEST PRACTICES =====
      'array-callback-return': 'error',
      'block-scoped-var': 'error',
      'consistent-return': 'error',
      curly: ['error', 'all'],
      'default-case': 'warn',
      'default-case-last': 'error',
      'dot-notation': ['error', { allowKeywords: true }],
      eqeqeq: ['error', 'always', { null: 'ignore' }],
      'no-alert': 'error',
      'no-case-declarations': 'error',
      'no-constructor-return': 'error',
      'no-else-return': ['warn', { allowElseIf: false }],
      'no-empty-function': ['warn', { allow: [] }],
      'no-empty-pattern': 'error',
      'no-fallthrough': 'error',
      'no-global-assign': 'error',
      'no-implicit-coercion': ['warn', { allow: ['!!'] }],
      'no-implicit-globals': 'error',
      'no-lone-blocks': 'error',
      'no-loop-func': 'error',
      'no-multi-spaces': 'error',
      'no-new': 'warn',
      'no-new-wrappers': 'error',
      'no-octal': 'error',
      'no-octal-escape': 'error',
      'no-param-reassign': ['warn', { props: false }],
      'no-redeclare': 'error',
      'no-self-assign': 'error',
      'no-self-compare': 'error',
      'no-sequences': 'error',
      'no-unmodified-loop-condition': 'error',
      'no-useless-call': 'error',
      'no-useless-catch': 'error',
      'no-useless-concat': 'error',
      'no-useless-escape': 'error',
      'no-useless-return': 'error',
      'no-void': 'error',
      'prefer-regex-literals': 'error',
      radix: 'error',
      'require-await': 'warn',
      yoda: ['error', 'never'],

      // ===== VARIABLES =====
      'no-delete-var': 'error',
      'no-label-var': 'error',
      'no-shadow': ['error', {
        builtinGlobals: false,
        hoist: 'functions',
        allow: ['resolve', 'reject', 'done', 'next', 'err', 'error', 'cb'],
      }],
      'no-shadow-restricted-names': 'error',
      'no-use-before-define': ['error', {
        functions: false,
        classes: true,
        variables: true,
      }],

      // ===== NODE.JS AND COMMONJS PATTERNS =====
      'no-buffer-constructor': 'error',
      'no-new-require': 'error',
      'no-path-concat': 'error',
      'no-process-exit': 'warn',

      // ===== STYLISTIC RULES (Google Style Guide inspired) =====
      'brace-style': ['error', '1tbs', { allowSingleLine: true }],
      camelcase: ['error', {
        properties: 'never',
        ignoreDestructuring: true,
        ignoreImports: true,
        ignoreGlobals: true,
      }],
      'comma-dangle': ['error', {
        arrays: 'always-multiline',
        objects: 'always-multiline',
        imports: 'always-multiline',
        exports: 'always-multiline',
        functions: 'never',
      }],
      'comma-spacing': ['error', { before: false, after: true }],
      'comma-style': ['error', 'last'],
      'computed-property-spacing': ['error', 'never'],
      'eol-last': ['error', 'always'],
      'func-call-spacing': ['error', 'never'],
      indent: ['error', 2, {
        SwitchCase: 1,
        VariableDeclarator: 'first',
        outerIIFEBody: 1,
        MemberExpression: 1,
        FunctionDeclaration: { parameters: 'first', body: 1 },
        FunctionExpression: { parameters: 'first', body: 1 },
        CallExpression: { arguments: 'first' },
        ArrayExpression: 1,
        ObjectExpression: 1,
        ImportDeclaration: 1,
        flatTernaryExpressions: false,
        ignoreComments: false,
      }],
      'key-spacing': ['error', { beforeColon: false, afterColon: true }],
      'keyword-spacing': ['error', { before: true, after: true }],
      'linebreak-style': ['error', 'unix'],
      'lines-between-class-members': ['error', 'always', { exceptAfterSingleLine: true }],
      'max-len': ['warn', {
        code: 100,
        tabWidth: 2,
        ignoreUrls: true,
        ignoreStrings: true,
        ignoreTemplateLiterals: true,
        ignoreRegExpLiterals: true,
        ignoreComments: true,
      }],
      'new-cap': ['error', {
        newIsCap: true,
        capIsNew: false,
        properties: true,
      }],
      'new-parens': 'error',
      'no-array-constructor': 'error',
      'no-mixed-spaces-and-tabs': 'error',
      'no-multiple-empty-lines': ['error', { max: 2, maxEOF: 1, maxBOF: 0 }],
      'no-new-object': 'error',
      'no-tabs': 'error',
      'no-trailing-spaces': 'error',
      'no-whitespace-before-property': 'error',
      'object-curly-spacing': ['error', 'always'],
      'one-var': ['error', 'never'],
      'operator-linebreak': ['error', 'after', {
        overrides: { '?': 'before', ':': 'before' },
      }],
      'padded-blocks': ['error', 'never'],
      'quote-props': ['error', 'as-needed'],
      quotes: ['error', 'single', { avoidEscape: true, allowTemplateLiterals: true }],
      semi: ['error', 'always'],
      'semi-spacing': ['error', { before: false, after: true }],
      'semi-style': ['error', 'last'],
      'space-before-blocks': ['error', 'always'],
      'space-before-function-paren': ['error', {
        anonymous: 'always',
        named: 'never',
        asyncArrow: 'always',
      }],
      'space-in-parens': ['error', 'never'],
      'space-infix-ops': 'error',
      'space-unary-ops': ['error', { words: true, nonwords: false }],
      'spaced-comment': ['error', 'always', {
        line: { markers: ['/'], exceptions: ['-', '+'] },
        block: { markers: ['!'], exceptions: ['*'], balanced: true },
      }],

      // ===== ES6+ FEATURES =====
      'arrow-body-style': ['warn', 'as-needed'],
      'arrow-parens': ['error', 'always'],
      'arrow-spacing': ['error', { before: true, after: true }],
      'constructor-super': 'error',
      'generator-star-spacing': ['error', { before: false, after: true }],
      'no-class-assign': 'error',
      'no-confusing-arrow': ['error', { allowParens: true }],
      'no-const-assign': 'error',
      'no-dupe-class-members': 'error',
      'no-duplicate-imports': 'error',
      'no-new-symbol': 'error',
      'no-this-before-super': 'error',
      'no-useless-computed-key': 'error',
      'no-useless-constructor': 'error',
      'no-useless-rename': 'error',
      'no-var': 'error',
      'object-shorthand': ['error', 'always'],
      'prefer-arrow-callback': ['error', { allowNamedFunctions: false }],
      'prefer-const': ['error', { destructuring: 'all' }],
      'prefer-destructuring': ['warn', {
        array: false,
        object: true,
      }, {
        enforceForRenamedProperties: false,
      }],
      'prefer-rest-params': 'error',
      'prefer-spread': 'error',
      'prefer-template': 'warn',
      'require-yield': 'error',
      'rest-spread-spacing': ['error', 'never'],
      'symbol-description': 'error',
      'template-curly-spacing': ['error', 'never'],
      'yield-star-spacing': ['error', 'after'],
    },
  },

  // Configuration for test files
  {
    files: ['**/*.test.js', '**/*.spec.js', '**/test/**/*.js', '**/tests/**/*.js'],
    languageOptions: {
      globals: {
        ...globals.jest,
        ...globals.mocha,
      },
    },
    rules: {
      'no-unused-expressions': 'off',
      'max-len': 'off',
      'prefer-arrow-callback': 'off',
    },
  },

  // Configuration for config files
  {
    files: ['*.config.js', '.eslintrc.js', 'eslint.config.mjs'],
    rules: {
      'no-console': 'off',
    },
  },
];

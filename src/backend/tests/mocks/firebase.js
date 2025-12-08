const mockCollection = jest.fn();
const mockDoc = jest.fn();
const mockGet = jest.fn();
const mockWhere = jest.fn();
const mockLimit = jest.fn();

mockCollection.mockReturnValue({
  doc: mockDoc,
  where: mockWhere,
  limit: mockLimit,
});

mockDoc.mockReturnValue({
  collection: mockCollection,
  get: mockGet,
});

mockWhere.mockReturnValue({
  limit: mockLimit,
  get: mockGet,
});

mockLimit.mockReturnValue({
  get: mockGet,
});

module.exports = {
  firestore: () => ({
    collection: mockCollection,
  }),
  __mock: {
    mockCollection,
    mockDoc,
    mockGet,
    mockWhere,
    mockLimit,
  },
};

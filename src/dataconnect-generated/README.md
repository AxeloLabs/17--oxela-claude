# Generated TypeScript README
This README will guide you through the process of using the generated JavaScript SDK package for the connector `ecommerce`. It will also provide examples on how to use your generated SDK to call your Data Connect queries and mutations.

***NOTE:** This README is generated alongside the generated SDK. If you make changes to this file, they will be overwritten when the SDK is regenerated.*

# Table of Contents
- [**Overview**](#generated-javascript-readme)
- [**Accessing the connector**](#accessing-the-connector)
  - [*Connecting to the local Emulator*](#connecting-to-the-local-emulator)
- [**Queries**](#queries)
  - [*GetUserByFirebaseUid*](#getuserbyfirebaseuid)
  - [*ListUsers*](#listusers)
  - [*ListProducts*](#listproducts)
  - [*GetProductBySlug*](#getproductbyslug)
  - [*SearchProducts*](#searchproducts)
  - [*ListCategories*](#listcategories)
  - [*GetCategoryBySlug*](#getcategorybyslug)
  - [*GetProductsByCategory*](#getproductsbycategory)
  - [*GetUserCart*](#getusercart)
  - [*GetCartItemWithProduct*](#getcartitemwithproduct)
  - [*ListUserOrders*](#listuserorders)
  - [*GetOrderById*](#getorderbyid)
  - [*GetOrderItems*](#getorderitems)
  - [*ListAllOrders*](#listallorders)
  - [*GetProductReviews*](#getproductreviews)
  - [*GetUserReviews*](#getuserreviews)
- [**Mutations**](#mutations)
  - [*CreateUser*](#createuser)
  - [*UpdateUser*](#updateuser)
  - [*CreateProduct*](#createproduct)
  - [*UpdateProduct*](#updateproduct)
  - [*DeleteProduct*](#deleteproduct)
  - [*CreateCategory*](#createcategory)
  - [*UpdateCategory*](#updatecategory)
  - [*AddToCart*](#addtocart)
  - [*UpdateCartItemQuantity*](#updatecartitemquantity)
  - [*RemoveFromCart*](#removefromcart)
  - [*ClearCart*](#clearcart)
  - [*CreateOrder*](#createorder)
  - [*AddOrderItem*](#addorderitem)
  - [*UpdateOrderStatus*](#updateorderstatus)
  - [*CreateReview*](#createreview)
  - [*UpdateReview*](#updatereview)
  - [*VerifyReview*](#verifyreview)
  - [*DeleteReview*](#deletereview)

# Accessing the connector
A connector is a collection of Queries and Mutations. One SDK is generated for each connector - this SDK is generated for the connector `ecommerce`. You can find more information about connectors in the [Data Connect documentation](https://firebase.google.com/docs/data-connect#how-does).

You can use this generated SDK by importing from the package `@dataconnect/generated` as shown below. Both CommonJS and ESM imports are supported.

You can also follow the instructions from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#set-client).

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig } from '@dataconnect/generated';

const dataConnect = getDataConnect(connectorConfig);
```

## Connecting to the local Emulator
By default, the connector will connect to the production service.

To connect to the emulator, you can use the following code.
You can also follow the emulator instructions from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#instrument-clients).

```typescript
import { connectDataConnectEmulator, getDataConnect } from 'firebase/data-connect';
import { connectorConfig } from '@dataconnect/generated';

const dataConnect = getDataConnect(connectorConfig);
connectDataConnectEmulator(dataConnect, 'localhost', 9399);
```

After it's initialized, you can call your Data Connect [queries](#queries) and [mutations](#mutations) from your generated SDK.

# Queries

There are two ways to execute a Data Connect Query using the generated Web SDK:
- Using a Query Reference function, which returns a `QueryRef`
  - The `QueryRef` can be used as an argument to `executeQuery()`, which will execute the Query and return a `QueryPromise`
- Using an action shortcut function, which returns a `QueryPromise`
  - Calling the action shortcut function will execute the Query and return a `QueryPromise`

The following is true for both the action shortcut function and the `QueryRef` function:
- The `QueryPromise` returned will resolve to the result of the Query once it has finished executing
- If the Query accepts arguments, both the action shortcut function and the `QueryRef` function accept a single argument: an object that contains all the required variables (and the optional variables) for the Query
- Both functions can be called with or without passing in a `DataConnect` instance as an argument. If no `DataConnect` argument is passed in, then the generated SDK will call `getDataConnect(connectorConfig)` behind the scenes for you.

Below are examples of how to use the `ecommerce` connector's generated functions to execute each query. You can also follow the examples from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#using-queries).

## GetUserByFirebaseUid
You can execute the `GetUserByFirebaseUid` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getUserByFirebaseUid(vars: GetUserByFirebaseUidVariables): QueryPromise<GetUserByFirebaseUidData, GetUserByFirebaseUidVariables>;

interface GetUserByFirebaseUidRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetUserByFirebaseUidVariables): QueryRef<GetUserByFirebaseUidData, GetUserByFirebaseUidVariables>;
}
export const getUserByFirebaseUidRef: GetUserByFirebaseUidRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getUserByFirebaseUid(dc: DataConnect, vars: GetUserByFirebaseUidVariables): QueryPromise<GetUserByFirebaseUidData, GetUserByFirebaseUidVariables>;

interface GetUserByFirebaseUidRef {
  ...
  (dc: DataConnect, vars: GetUserByFirebaseUidVariables): QueryRef<GetUserByFirebaseUidData, GetUserByFirebaseUidVariables>;
}
export const getUserByFirebaseUidRef: GetUserByFirebaseUidRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getUserByFirebaseUidRef:
```typescript
const name = getUserByFirebaseUidRef.operationName;
console.log(name);
```

### Variables
The `GetUserByFirebaseUid` query requires an argument of type `GetUserByFirebaseUidVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetUserByFirebaseUidVariables {
  firebaseUid: string;
}
```
### Return Type
Recall that executing the `GetUserByFirebaseUid` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetUserByFirebaseUidData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetUserByFirebaseUidData {
  users: ({
    id: UUIDString;
    firebaseUid: string;
    email: string;
    displayName?: string | null;
    photoURL?: string | null;
    role: UserRole;
    createdAt: TimestampString;
  } & User_Key)[];
}
```
### Using `GetUserByFirebaseUid`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getUserByFirebaseUid, GetUserByFirebaseUidVariables } from '@dataconnect/generated';

// The `GetUserByFirebaseUid` query requires an argument of type `GetUserByFirebaseUidVariables`:
const getUserByFirebaseUidVars: GetUserByFirebaseUidVariables = {
  firebaseUid: ..., 
};

// Call the `getUserByFirebaseUid()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getUserByFirebaseUid(getUserByFirebaseUidVars);
// Variables can be defined inline as well.
const { data } = await getUserByFirebaseUid({ firebaseUid: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getUserByFirebaseUid(dataConnect, getUserByFirebaseUidVars);

console.log(data.users);

// Or, you can use the `Promise` API.
getUserByFirebaseUid(getUserByFirebaseUidVars).then((response) => {
  const data = response.data;
  console.log(data.users);
});
```

### Using `GetUserByFirebaseUid`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getUserByFirebaseUidRef, GetUserByFirebaseUidVariables } from '@dataconnect/generated';

// The `GetUserByFirebaseUid` query requires an argument of type `GetUserByFirebaseUidVariables`:
const getUserByFirebaseUidVars: GetUserByFirebaseUidVariables = {
  firebaseUid: ..., 
};

// Call the `getUserByFirebaseUidRef()` function to get a reference to the query.
const ref = getUserByFirebaseUidRef(getUserByFirebaseUidVars);
// Variables can be defined inline as well.
const ref = getUserByFirebaseUidRef({ firebaseUid: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getUserByFirebaseUidRef(dataConnect, getUserByFirebaseUidVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.users);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.users);
});
```

## ListUsers
You can execute the `ListUsers` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
listUsers(): QueryPromise<ListUsersData, undefined>;

interface ListUsersRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListUsersData, undefined>;
}
export const listUsersRef: ListUsersRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listUsers(dc: DataConnect): QueryPromise<ListUsersData, undefined>;

interface ListUsersRef {
  ...
  (dc: DataConnect): QueryRef<ListUsersData, undefined>;
}
export const listUsersRef: ListUsersRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listUsersRef:
```typescript
const name = listUsersRef.operationName;
console.log(name);
```

### Variables
The `ListUsers` query has no variables.
### Return Type
Recall that executing the `ListUsers` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListUsersData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListUsersData {
  users: ({
    id: UUIDString;
    email: string;
    displayName?: string | null;
    role: UserRole;
    createdAt: TimestampString;
  } & User_Key)[];
}
```
### Using `ListUsers`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listUsers } from '@dataconnect/generated';


// Call the `listUsers()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listUsers();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listUsers(dataConnect);

console.log(data.users);

// Or, you can use the `Promise` API.
listUsers().then((response) => {
  const data = response.data;
  console.log(data.users);
});
```

### Using `ListUsers`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listUsersRef } from '@dataconnect/generated';


// Call the `listUsersRef()` function to get a reference to the query.
const ref = listUsersRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listUsersRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.users);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.users);
});
```

## ListProducts
You can execute the `ListProducts` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
listProducts(vars?: ListProductsVariables): QueryPromise<ListProductsData, ListProductsVariables>;

interface ListProductsRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars?: ListProductsVariables): QueryRef<ListProductsData, ListProductsVariables>;
}
export const listProductsRef: ListProductsRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listProducts(dc: DataConnect, vars?: ListProductsVariables): QueryPromise<ListProductsData, ListProductsVariables>;

interface ListProductsRef {
  ...
  (dc: DataConnect, vars?: ListProductsVariables): QueryRef<ListProductsData, ListProductsVariables>;
}
export const listProductsRef: ListProductsRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listProductsRef:
```typescript
const name = listProductsRef.operationName;
console.log(name);
```

### Variables
The `ListProducts` query has an optional argument of type `ListProductsVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface ListProductsVariables {
  limit?: number | null;
  offset?: number | null;
  categoryId?: UUIDString | null;
}
```
### Return Type
Recall that executing the `ListProducts` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListProductsData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListProductsData {
  products: ({
    id: UUIDString;
    name: string;
    slug: string;
    description: string;
    price: number;
    compareAtPrice?: number | null;
    stock: number;
    status: ProductStatus;
    imageUrl: string;
    images?: string[] | null;
    categoryId: UUIDString;
    createdAt: TimestampString;
  } & Product_Key)[];
}
```
### Using `ListProducts`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listProducts, ListProductsVariables } from '@dataconnect/generated';

// The `ListProducts` query has an optional argument of type `ListProductsVariables`:
const listProductsVars: ListProductsVariables = {
  limit: ..., // optional
  offset: ..., // optional
  categoryId: ..., // optional
};

// Call the `listProducts()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listProducts(listProductsVars);
// Variables can be defined inline as well.
const { data } = await listProducts({ limit: ..., offset: ..., categoryId: ..., });
// Since all variables are optional for this query, you can omit the `ListProductsVariables` argument.
const { data } = await listProducts();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listProducts(dataConnect, listProductsVars);

console.log(data.products);

// Or, you can use the `Promise` API.
listProducts(listProductsVars).then((response) => {
  const data = response.data;
  console.log(data.products);
});
```

### Using `ListProducts`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listProductsRef, ListProductsVariables } from '@dataconnect/generated';

// The `ListProducts` query has an optional argument of type `ListProductsVariables`:
const listProductsVars: ListProductsVariables = {
  limit: ..., // optional
  offset: ..., // optional
  categoryId: ..., // optional
};

// Call the `listProductsRef()` function to get a reference to the query.
const ref = listProductsRef(listProductsVars);
// Variables can be defined inline as well.
const ref = listProductsRef({ limit: ..., offset: ..., categoryId: ..., });
// Since all variables are optional for this query, you can omit the `ListProductsVariables` argument.
const ref = listProductsRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listProductsRef(dataConnect, listProductsVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.products);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.products);
});
```

## GetProductBySlug
You can execute the `GetProductBySlug` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getProductBySlug(vars: GetProductBySlugVariables): QueryPromise<GetProductBySlugData, GetProductBySlugVariables>;

interface GetProductBySlugRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetProductBySlugVariables): QueryRef<GetProductBySlugData, GetProductBySlugVariables>;
}
export const getProductBySlugRef: GetProductBySlugRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getProductBySlug(dc: DataConnect, vars: GetProductBySlugVariables): QueryPromise<GetProductBySlugData, GetProductBySlugVariables>;

interface GetProductBySlugRef {
  ...
  (dc: DataConnect, vars: GetProductBySlugVariables): QueryRef<GetProductBySlugData, GetProductBySlugVariables>;
}
export const getProductBySlugRef: GetProductBySlugRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getProductBySlugRef:
```typescript
const name = getProductBySlugRef.operationName;
console.log(name);
```

### Variables
The `GetProductBySlug` query requires an argument of type `GetProductBySlugVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetProductBySlugVariables {
  slug: string;
}
```
### Return Type
Recall that executing the `GetProductBySlug` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetProductBySlugData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetProductBySlugData {
  products: ({
    id: UUIDString;
    name: string;
    slug: string;
    description: string;
    price: number;
    compareAtPrice?: number | null;
    stock: number;
    status: ProductStatus;
    imageUrl: string;
    images?: string[] | null;
    sku?: string | null;
    weight?: number | null;
    dimensions?: string | null;
    categoryId: UUIDString;
    createdAt: TimestampString;
    updatedAt: TimestampString;
  } & Product_Key)[];
}
```
### Using `GetProductBySlug`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getProductBySlug, GetProductBySlugVariables } from '@dataconnect/generated';

// The `GetProductBySlug` query requires an argument of type `GetProductBySlugVariables`:
const getProductBySlugVars: GetProductBySlugVariables = {
  slug: ..., 
};

// Call the `getProductBySlug()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getProductBySlug(getProductBySlugVars);
// Variables can be defined inline as well.
const { data } = await getProductBySlug({ slug: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getProductBySlug(dataConnect, getProductBySlugVars);

console.log(data.products);

// Or, you can use the `Promise` API.
getProductBySlug(getProductBySlugVars).then((response) => {
  const data = response.data;
  console.log(data.products);
});
```

### Using `GetProductBySlug`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getProductBySlugRef, GetProductBySlugVariables } from '@dataconnect/generated';

// The `GetProductBySlug` query requires an argument of type `GetProductBySlugVariables`:
const getProductBySlugVars: GetProductBySlugVariables = {
  slug: ..., 
};

// Call the `getProductBySlugRef()` function to get a reference to the query.
const ref = getProductBySlugRef(getProductBySlugVars);
// Variables can be defined inline as well.
const ref = getProductBySlugRef({ slug: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getProductBySlugRef(dataConnect, getProductBySlugVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.products);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.products);
});
```

## SearchProducts
You can execute the `SearchProducts` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
searchProducts(vars: SearchProductsVariables): QueryPromise<SearchProductsData, SearchProductsVariables>;

interface SearchProductsRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: SearchProductsVariables): QueryRef<SearchProductsData, SearchProductsVariables>;
}
export const searchProductsRef: SearchProductsRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
searchProducts(dc: DataConnect, vars: SearchProductsVariables): QueryPromise<SearchProductsData, SearchProductsVariables>;

interface SearchProductsRef {
  ...
  (dc: DataConnect, vars: SearchProductsVariables): QueryRef<SearchProductsData, SearchProductsVariables>;
}
export const searchProductsRef: SearchProductsRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the searchProductsRef:
```typescript
const name = searchProductsRef.operationName;
console.log(name);
```

### Variables
The `SearchProducts` query requires an argument of type `SearchProductsVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface SearchProductsVariables {
  searchTerm: string;
}
```
### Return Type
Recall that executing the `SearchProducts` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `SearchProductsData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface SearchProductsData {
  products: ({
    id: UUIDString;
    name: string;
    slug: string;
    description: string;
    price: number;
    imageUrl: string;
    categoryId: UUIDString;
  } & Product_Key)[];
}
```
### Using `SearchProducts`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, searchProducts, SearchProductsVariables } from '@dataconnect/generated';

// The `SearchProducts` query requires an argument of type `SearchProductsVariables`:
const searchProductsVars: SearchProductsVariables = {
  searchTerm: ..., 
};

// Call the `searchProducts()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await searchProducts(searchProductsVars);
// Variables can be defined inline as well.
const { data } = await searchProducts({ searchTerm: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await searchProducts(dataConnect, searchProductsVars);

console.log(data.products);

// Or, you can use the `Promise` API.
searchProducts(searchProductsVars).then((response) => {
  const data = response.data;
  console.log(data.products);
});
```

### Using `SearchProducts`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, searchProductsRef, SearchProductsVariables } from '@dataconnect/generated';

// The `SearchProducts` query requires an argument of type `SearchProductsVariables`:
const searchProductsVars: SearchProductsVariables = {
  searchTerm: ..., 
};

// Call the `searchProductsRef()` function to get a reference to the query.
const ref = searchProductsRef(searchProductsVars);
// Variables can be defined inline as well.
const ref = searchProductsRef({ searchTerm: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = searchProductsRef(dataConnect, searchProductsVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.products);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.products);
});
```

## ListCategories
You can execute the `ListCategories` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
listCategories(): QueryPromise<ListCategoriesData, undefined>;

interface ListCategoriesRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListCategoriesData, undefined>;
}
export const listCategoriesRef: ListCategoriesRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listCategories(dc: DataConnect): QueryPromise<ListCategoriesData, undefined>;

interface ListCategoriesRef {
  ...
  (dc: DataConnect): QueryRef<ListCategoriesData, undefined>;
}
export const listCategoriesRef: ListCategoriesRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listCategoriesRef:
```typescript
const name = listCategoriesRef.operationName;
console.log(name);
```

### Variables
The `ListCategories` query has no variables.
### Return Type
Recall that executing the `ListCategories` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListCategoriesData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListCategoriesData {
  categories: ({
    id: UUIDString;
    name: string;
    slug: string;
    description?: string | null;
    imageUrl?: string | null;
    parentId?: UUIDString | null;
  } & Category_Key)[];
}
```
### Using `ListCategories`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listCategories } from '@dataconnect/generated';


// Call the `listCategories()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listCategories();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listCategories(dataConnect);

console.log(data.categories);

// Or, you can use the `Promise` API.
listCategories().then((response) => {
  const data = response.data;
  console.log(data.categories);
});
```

### Using `ListCategories`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listCategoriesRef } from '@dataconnect/generated';


// Call the `listCategoriesRef()` function to get a reference to the query.
const ref = listCategoriesRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listCategoriesRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.categories);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.categories);
});
```

## GetCategoryBySlug
You can execute the `GetCategoryBySlug` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getCategoryBySlug(vars: GetCategoryBySlugVariables): QueryPromise<GetCategoryBySlugData, GetCategoryBySlugVariables>;

interface GetCategoryBySlugRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetCategoryBySlugVariables): QueryRef<GetCategoryBySlugData, GetCategoryBySlugVariables>;
}
export const getCategoryBySlugRef: GetCategoryBySlugRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getCategoryBySlug(dc: DataConnect, vars: GetCategoryBySlugVariables): QueryPromise<GetCategoryBySlugData, GetCategoryBySlugVariables>;

interface GetCategoryBySlugRef {
  ...
  (dc: DataConnect, vars: GetCategoryBySlugVariables): QueryRef<GetCategoryBySlugData, GetCategoryBySlugVariables>;
}
export const getCategoryBySlugRef: GetCategoryBySlugRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getCategoryBySlugRef:
```typescript
const name = getCategoryBySlugRef.operationName;
console.log(name);
```

### Variables
The `GetCategoryBySlug` query requires an argument of type `GetCategoryBySlugVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetCategoryBySlugVariables {
  slug: string;
}
```
### Return Type
Recall that executing the `GetCategoryBySlug` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetCategoryBySlugData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetCategoryBySlugData {
  categories: ({
    id: UUIDString;
    name: string;
    slug: string;
    description?: string | null;
    imageUrl?: string | null;
    parentId?: UUIDString | null;
  } & Category_Key)[];
}
```
### Using `GetCategoryBySlug`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getCategoryBySlug, GetCategoryBySlugVariables } from '@dataconnect/generated';

// The `GetCategoryBySlug` query requires an argument of type `GetCategoryBySlugVariables`:
const getCategoryBySlugVars: GetCategoryBySlugVariables = {
  slug: ..., 
};

// Call the `getCategoryBySlug()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getCategoryBySlug(getCategoryBySlugVars);
// Variables can be defined inline as well.
const { data } = await getCategoryBySlug({ slug: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getCategoryBySlug(dataConnect, getCategoryBySlugVars);

console.log(data.categories);

// Or, you can use the `Promise` API.
getCategoryBySlug(getCategoryBySlugVars).then((response) => {
  const data = response.data;
  console.log(data.categories);
});
```

### Using `GetCategoryBySlug`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getCategoryBySlugRef, GetCategoryBySlugVariables } from '@dataconnect/generated';

// The `GetCategoryBySlug` query requires an argument of type `GetCategoryBySlugVariables`:
const getCategoryBySlugVars: GetCategoryBySlugVariables = {
  slug: ..., 
};

// Call the `getCategoryBySlugRef()` function to get a reference to the query.
const ref = getCategoryBySlugRef(getCategoryBySlugVars);
// Variables can be defined inline as well.
const ref = getCategoryBySlugRef({ slug: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getCategoryBySlugRef(dataConnect, getCategoryBySlugVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.categories);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.categories);
});
```

## GetProductsByCategory
You can execute the `GetProductsByCategory` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getProductsByCategory(vars: GetProductsByCategoryVariables): QueryPromise<GetProductsByCategoryData, GetProductsByCategoryVariables>;

interface GetProductsByCategoryRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetProductsByCategoryVariables): QueryRef<GetProductsByCategoryData, GetProductsByCategoryVariables>;
}
export const getProductsByCategoryRef: GetProductsByCategoryRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getProductsByCategory(dc: DataConnect, vars: GetProductsByCategoryVariables): QueryPromise<GetProductsByCategoryData, GetProductsByCategoryVariables>;

interface GetProductsByCategoryRef {
  ...
  (dc: DataConnect, vars: GetProductsByCategoryVariables): QueryRef<GetProductsByCategoryData, GetProductsByCategoryVariables>;
}
export const getProductsByCategoryRef: GetProductsByCategoryRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getProductsByCategoryRef:
```typescript
const name = getProductsByCategoryRef.operationName;
console.log(name);
```

### Variables
The `GetProductsByCategory` query requires an argument of type `GetProductsByCategoryVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetProductsByCategoryVariables {
  categoryId: UUIDString;
}
```
### Return Type
Recall that executing the `GetProductsByCategory` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetProductsByCategoryData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetProductsByCategoryData {
  products: ({
    id: UUIDString;
    name: string;
    slug: string;
    price: number;
    imageUrl: string;
    stock: number;
  } & Product_Key)[];
}
```
### Using `GetProductsByCategory`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getProductsByCategory, GetProductsByCategoryVariables } from '@dataconnect/generated';

// The `GetProductsByCategory` query requires an argument of type `GetProductsByCategoryVariables`:
const getProductsByCategoryVars: GetProductsByCategoryVariables = {
  categoryId: ..., 
};

// Call the `getProductsByCategory()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getProductsByCategory(getProductsByCategoryVars);
// Variables can be defined inline as well.
const { data } = await getProductsByCategory({ categoryId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getProductsByCategory(dataConnect, getProductsByCategoryVars);

console.log(data.products);

// Or, you can use the `Promise` API.
getProductsByCategory(getProductsByCategoryVars).then((response) => {
  const data = response.data;
  console.log(data.products);
});
```

### Using `GetProductsByCategory`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getProductsByCategoryRef, GetProductsByCategoryVariables } from '@dataconnect/generated';

// The `GetProductsByCategory` query requires an argument of type `GetProductsByCategoryVariables`:
const getProductsByCategoryVars: GetProductsByCategoryVariables = {
  categoryId: ..., 
};

// Call the `getProductsByCategoryRef()` function to get a reference to the query.
const ref = getProductsByCategoryRef(getProductsByCategoryVars);
// Variables can be defined inline as well.
const ref = getProductsByCategoryRef({ categoryId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getProductsByCategoryRef(dataConnect, getProductsByCategoryVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.products);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.products);
});
```

## GetUserCart
You can execute the `GetUserCart` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getUserCart(vars: GetUserCartVariables): QueryPromise<GetUserCartData, GetUserCartVariables>;

interface GetUserCartRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetUserCartVariables): QueryRef<GetUserCartData, GetUserCartVariables>;
}
export const getUserCartRef: GetUserCartRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getUserCart(dc: DataConnect, vars: GetUserCartVariables): QueryPromise<GetUserCartData, GetUserCartVariables>;

interface GetUserCartRef {
  ...
  (dc: DataConnect, vars: GetUserCartVariables): QueryRef<GetUserCartData, GetUserCartVariables>;
}
export const getUserCartRef: GetUserCartRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getUserCartRef:
```typescript
const name = getUserCartRef.operationName;
console.log(name);
```

### Variables
The `GetUserCart` query requires an argument of type `GetUserCartVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetUserCartVariables {
  userId: UUIDString;
}
```
### Return Type
Recall that executing the `GetUserCart` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetUserCartData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetUserCartData {
  cartItems: ({
    id: UUIDString;
    quantity: number;
    productId: UUIDString;
    createdAt: TimestampString;
  } & CartItem_Key)[];
}
```
### Using `GetUserCart`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getUserCart, GetUserCartVariables } from '@dataconnect/generated';

// The `GetUserCart` query requires an argument of type `GetUserCartVariables`:
const getUserCartVars: GetUserCartVariables = {
  userId: ..., 
};

// Call the `getUserCart()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getUserCart(getUserCartVars);
// Variables can be defined inline as well.
const { data } = await getUserCart({ userId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getUserCart(dataConnect, getUserCartVars);

console.log(data.cartItems);

// Or, you can use the `Promise` API.
getUserCart(getUserCartVars).then((response) => {
  const data = response.data;
  console.log(data.cartItems);
});
```

### Using `GetUserCart`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getUserCartRef, GetUserCartVariables } from '@dataconnect/generated';

// The `GetUserCart` query requires an argument of type `GetUserCartVariables`:
const getUserCartVars: GetUserCartVariables = {
  userId: ..., 
};

// Call the `getUserCartRef()` function to get a reference to the query.
const ref = getUserCartRef(getUserCartVars);
// Variables can be defined inline as well.
const ref = getUserCartRef({ userId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getUserCartRef(dataConnect, getUserCartVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.cartItems);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.cartItems);
});
```

## GetCartItemWithProduct
You can execute the `GetCartItemWithProduct` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getCartItemWithProduct(vars: GetCartItemWithProductVariables): QueryPromise<GetCartItemWithProductData, GetCartItemWithProductVariables>;

interface GetCartItemWithProductRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetCartItemWithProductVariables): QueryRef<GetCartItemWithProductData, GetCartItemWithProductVariables>;
}
export const getCartItemWithProductRef: GetCartItemWithProductRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getCartItemWithProduct(dc: DataConnect, vars: GetCartItemWithProductVariables): QueryPromise<GetCartItemWithProductData, GetCartItemWithProductVariables>;

interface GetCartItemWithProductRef {
  ...
  (dc: DataConnect, vars: GetCartItemWithProductVariables): QueryRef<GetCartItemWithProductData, GetCartItemWithProductVariables>;
}
export const getCartItemWithProductRef: GetCartItemWithProductRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getCartItemWithProductRef:
```typescript
const name = getCartItemWithProductRef.operationName;
console.log(name);
```

### Variables
The `GetCartItemWithProduct` query requires an argument of type `GetCartItemWithProductVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetCartItemWithProductVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `GetCartItemWithProduct` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetCartItemWithProductData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetCartItemWithProductData {
  cartItems: ({
    id: UUIDString;
    quantity: number;
    productId: UUIDString;
    userId: UUIDString;
  } & CartItem_Key)[];
}
```
### Using `GetCartItemWithProduct`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getCartItemWithProduct, GetCartItemWithProductVariables } from '@dataconnect/generated';

// The `GetCartItemWithProduct` query requires an argument of type `GetCartItemWithProductVariables`:
const getCartItemWithProductVars: GetCartItemWithProductVariables = {
  id: ..., 
};

// Call the `getCartItemWithProduct()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getCartItemWithProduct(getCartItemWithProductVars);
// Variables can be defined inline as well.
const { data } = await getCartItemWithProduct({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getCartItemWithProduct(dataConnect, getCartItemWithProductVars);

console.log(data.cartItems);

// Or, you can use the `Promise` API.
getCartItemWithProduct(getCartItemWithProductVars).then((response) => {
  const data = response.data;
  console.log(data.cartItems);
});
```

### Using `GetCartItemWithProduct`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getCartItemWithProductRef, GetCartItemWithProductVariables } from '@dataconnect/generated';

// The `GetCartItemWithProduct` query requires an argument of type `GetCartItemWithProductVariables`:
const getCartItemWithProductVars: GetCartItemWithProductVariables = {
  id: ..., 
};

// Call the `getCartItemWithProductRef()` function to get a reference to the query.
const ref = getCartItemWithProductRef(getCartItemWithProductVars);
// Variables can be defined inline as well.
const ref = getCartItemWithProductRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getCartItemWithProductRef(dataConnect, getCartItemWithProductVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.cartItems);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.cartItems);
});
```

## ListUserOrders
You can execute the `ListUserOrders` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
listUserOrders(vars: ListUserOrdersVariables): QueryPromise<ListUserOrdersData, ListUserOrdersVariables>;

interface ListUserOrdersRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: ListUserOrdersVariables): QueryRef<ListUserOrdersData, ListUserOrdersVariables>;
}
export const listUserOrdersRef: ListUserOrdersRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listUserOrders(dc: DataConnect, vars: ListUserOrdersVariables): QueryPromise<ListUserOrdersData, ListUserOrdersVariables>;

interface ListUserOrdersRef {
  ...
  (dc: DataConnect, vars: ListUserOrdersVariables): QueryRef<ListUserOrdersData, ListUserOrdersVariables>;
}
export const listUserOrdersRef: ListUserOrdersRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listUserOrdersRef:
```typescript
const name = listUserOrdersRef.operationName;
console.log(name);
```

### Variables
The `ListUserOrders` query requires an argument of type `ListUserOrdersVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface ListUserOrdersVariables {
  userId: UUIDString;
}
```
### Return Type
Recall that executing the `ListUserOrders` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListUserOrdersData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListUserOrdersData {
  orders: ({
    id: UUIDString;
    orderNumber: string;
    status: OrderStatus;
    total: number;
    createdAt: TimestampString;
  } & Order_Key)[];
}
```
### Using `ListUserOrders`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listUserOrders, ListUserOrdersVariables } from '@dataconnect/generated';

// The `ListUserOrders` query requires an argument of type `ListUserOrdersVariables`:
const listUserOrdersVars: ListUserOrdersVariables = {
  userId: ..., 
};

// Call the `listUserOrders()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listUserOrders(listUserOrdersVars);
// Variables can be defined inline as well.
const { data } = await listUserOrders({ userId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listUserOrders(dataConnect, listUserOrdersVars);

console.log(data.orders);

// Or, you can use the `Promise` API.
listUserOrders(listUserOrdersVars).then((response) => {
  const data = response.data;
  console.log(data.orders);
});
```

### Using `ListUserOrders`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listUserOrdersRef, ListUserOrdersVariables } from '@dataconnect/generated';

// The `ListUserOrders` query requires an argument of type `ListUserOrdersVariables`:
const listUserOrdersVars: ListUserOrdersVariables = {
  userId: ..., 
};

// Call the `listUserOrdersRef()` function to get a reference to the query.
const ref = listUserOrdersRef(listUserOrdersVars);
// Variables can be defined inline as well.
const ref = listUserOrdersRef({ userId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listUserOrdersRef(dataConnect, listUserOrdersVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.orders);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.orders);
});
```

## GetOrderById
You can execute the `GetOrderById` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getOrderById(vars: GetOrderByIdVariables): QueryPromise<GetOrderByIdData, GetOrderByIdVariables>;

interface GetOrderByIdRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetOrderByIdVariables): QueryRef<GetOrderByIdData, GetOrderByIdVariables>;
}
export const getOrderByIdRef: GetOrderByIdRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getOrderById(dc: DataConnect, vars: GetOrderByIdVariables): QueryPromise<GetOrderByIdData, GetOrderByIdVariables>;

interface GetOrderByIdRef {
  ...
  (dc: DataConnect, vars: GetOrderByIdVariables): QueryRef<GetOrderByIdData, GetOrderByIdVariables>;
}
export const getOrderByIdRef: GetOrderByIdRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getOrderByIdRef:
```typescript
const name = getOrderByIdRef.operationName;
console.log(name);
```

### Variables
The `GetOrderById` query requires an argument of type `GetOrderByIdVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetOrderByIdVariables {
  orderId: UUIDString;
}
```
### Return Type
Recall that executing the `GetOrderById` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetOrderByIdData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetOrderByIdData {
  orders: ({
    id: UUIDString;
    orderNumber: string;
    status: OrderStatus;
    subtotal: number;
    shippingCost: number;
    tax: number;
    total: number;
    shippingName: string;
    shippingAddress: string;
    shippingCity: string;
    shippingPostalCode: string;
    shippingCountry: string;
    billingName: string;
    billingAddress: string;
    billingCity: string;
    billingPostalCode: string;
    billingCountry: string;
    paymentMethod: string;
    paymentStatus: string;
    createdAt: TimestampString;
    userId: UUIDString;
  } & Order_Key)[];
}
```
### Using `GetOrderById`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getOrderById, GetOrderByIdVariables } from '@dataconnect/generated';

// The `GetOrderById` query requires an argument of type `GetOrderByIdVariables`:
const getOrderByIdVars: GetOrderByIdVariables = {
  orderId: ..., 
};

// Call the `getOrderById()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getOrderById(getOrderByIdVars);
// Variables can be defined inline as well.
const { data } = await getOrderById({ orderId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getOrderById(dataConnect, getOrderByIdVars);

console.log(data.orders);

// Or, you can use the `Promise` API.
getOrderById(getOrderByIdVars).then((response) => {
  const data = response.data;
  console.log(data.orders);
});
```

### Using `GetOrderById`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getOrderByIdRef, GetOrderByIdVariables } from '@dataconnect/generated';

// The `GetOrderById` query requires an argument of type `GetOrderByIdVariables`:
const getOrderByIdVars: GetOrderByIdVariables = {
  orderId: ..., 
};

// Call the `getOrderByIdRef()` function to get a reference to the query.
const ref = getOrderByIdRef(getOrderByIdVars);
// Variables can be defined inline as well.
const ref = getOrderByIdRef({ orderId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getOrderByIdRef(dataConnect, getOrderByIdVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.orders);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.orders);
});
```

## GetOrderItems
You can execute the `GetOrderItems` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getOrderItems(vars: GetOrderItemsVariables): QueryPromise<GetOrderItemsData, GetOrderItemsVariables>;

interface GetOrderItemsRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetOrderItemsVariables): QueryRef<GetOrderItemsData, GetOrderItemsVariables>;
}
export const getOrderItemsRef: GetOrderItemsRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getOrderItems(dc: DataConnect, vars: GetOrderItemsVariables): QueryPromise<GetOrderItemsData, GetOrderItemsVariables>;

interface GetOrderItemsRef {
  ...
  (dc: DataConnect, vars: GetOrderItemsVariables): QueryRef<GetOrderItemsData, GetOrderItemsVariables>;
}
export const getOrderItemsRef: GetOrderItemsRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getOrderItemsRef:
```typescript
const name = getOrderItemsRef.operationName;
console.log(name);
```

### Variables
The `GetOrderItems` query requires an argument of type `GetOrderItemsVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetOrderItemsVariables {
  orderId: UUIDString;
}
```
### Return Type
Recall that executing the `GetOrderItems` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetOrderItemsData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetOrderItemsData {
  orderItems: ({
    id: UUIDString;
    quantity: number;
    priceAtTime: number;
    subtotal: number;
    productId: UUIDString;
  } & OrderItem_Key)[];
}
```
### Using `GetOrderItems`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getOrderItems, GetOrderItemsVariables } from '@dataconnect/generated';

// The `GetOrderItems` query requires an argument of type `GetOrderItemsVariables`:
const getOrderItemsVars: GetOrderItemsVariables = {
  orderId: ..., 
};

// Call the `getOrderItems()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getOrderItems(getOrderItemsVars);
// Variables can be defined inline as well.
const { data } = await getOrderItems({ orderId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getOrderItems(dataConnect, getOrderItemsVars);

console.log(data.orderItems);

// Or, you can use the `Promise` API.
getOrderItems(getOrderItemsVars).then((response) => {
  const data = response.data;
  console.log(data.orderItems);
});
```

### Using `GetOrderItems`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getOrderItemsRef, GetOrderItemsVariables } from '@dataconnect/generated';

// The `GetOrderItems` query requires an argument of type `GetOrderItemsVariables`:
const getOrderItemsVars: GetOrderItemsVariables = {
  orderId: ..., 
};

// Call the `getOrderItemsRef()` function to get a reference to the query.
const ref = getOrderItemsRef(getOrderItemsVars);
// Variables can be defined inline as well.
const ref = getOrderItemsRef({ orderId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getOrderItemsRef(dataConnect, getOrderItemsVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.orderItems);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.orderItems);
});
```

## ListAllOrders
You can execute the `ListAllOrders` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
listAllOrders(vars?: ListAllOrdersVariables): QueryPromise<ListAllOrdersData, ListAllOrdersVariables>;

interface ListAllOrdersRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars?: ListAllOrdersVariables): QueryRef<ListAllOrdersData, ListAllOrdersVariables>;
}
export const listAllOrdersRef: ListAllOrdersRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listAllOrders(dc: DataConnect, vars?: ListAllOrdersVariables): QueryPromise<ListAllOrdersData, ListAllOrdersVariables>;

interface ListAllOrdersRef {
  ...
  (dc: DataConnect, vars?: ListAllOrdersVariables): QueryRef<ListAllOrdersData, ListAllOrdersVariables>;
}
export const listAllOrdersRef: ListAllOrdersRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listAllOrdersRef:
```typescript
const name = listAllOrdersRef.operationName;
console.log(name);
```

### Variables
The `ListAllOrders` query has an optional argument of type `ListAllOrdersVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface ListAllOrdersVariables {
  status?: OrderStatus | null;
}
```
### Return Type
Recall that executing the `ListAllOrders` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListAllOrdersData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListAllOrdersData {
  orders: ({
    id: UUIDString;
    orderNumber: string;
    status: OrderStatus;
    total: number;
    userId: UUIDString;
    createdAt: TimestampString;
  } & Order_Key)[];
}
```
### Using `ListAllOrders`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listAllOrders, ListAllOrdersVariables } from '@dataconnect/generated';

// The `ListAllOrders` query has an optional argument of type `ListAllOrdersVariables`:
const listAllOrdersVars: ListAllOrdersVariables = {
  status: ..., // optional
};

// Call the `listAllOrders()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listAllOrders(listAllOrdersVars);
// Variables can be defined inline as well.
const { data } = await listAllOrders({ status: ..., });
// Since all variables are optional for this query, you can omit the `ListAllOrdersVariables` argument.
const { data } = await listAllOrders();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listAllOrders(dataConnect, listAllOrdersVars);

console.log(data.orders);

// Or, you can use the `Promise` API.
listAllOrders(listAllOrdersVars).then((response) => {
  const data = response.data;
  console.log(data.orders);
});
```

### Using `ListAllOrders`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listAllOrdersRef, ListAllOrdersVariables } from '@dataconnect/generated';

// The `ListAllOrders` query has an optional argument of type `ListAllOrdersVariables`:
const listAllOrdersVars: ListAllOrdersVariables = {
  status: ..., // optional
};

// Call the `listAllOrdersRef()` function to get a reference to the query.
const ref = listAllOrdersRef(listAllOrdersVars);
// Variables can be defined inline as well.
const ref = listAllOrdersRef({ status: ..., });
// Since all variables are optional for this query, you can omit the `ListAllOrdersVariables` argument.
const ref = listAllOrdersRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listAllOrdersRef(dataConnect, listAllOrdersVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.orders);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.orders);
});
```

## GetProductReviews
You can execute the `GetProductReviews` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getProductReviews(vars: GetProductReviewsVariables): QueryPromise<GetProductReviewsData, GetProductReviewsVariables>;

interface GetProductReviewsRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetProductReviewsVariables): QueryRef<GetProductReviewsData, GetProductReviewsVariables>;
}
export const getProductReviewsRef: GetProductReviewsRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getProductReviews(dc: DataConnect, vars: GetProductReviewsVariables): QueryPromise<GetProductReviewsData, GetProductReviewsVariables>;

interface GetProductReviewsRef {
  ...
  (dc: DataConnect, vars: GetProductReviewsVariables): QueryRef<GetProductReviewsData, GetProductReviewsVariables>;
}
export const getProductReviewsRef: GetProductReviewsRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getProductReviewsRef:
```typescript
const name = getProductReviewsRef.operationName;
console.log(name);
```

### Variables
The `GetProductReviews` query requires an argument of type `GetProductReviewsVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetProductReviewsVariables {
  productId: UUIDString;
  limit?: number | null;
}
```
### Return Type
Recall that executing the `GetProductReviews` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetProductReviewsData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetProductReviewsData {
  reviews: ({
    id: UUIDString;
    rating: number;
    title?: string | null;
    comment: string;
    verified: boolean;
    userId: UUIDString;
    createdAt: TimestampString;
  } & Review_Key)[];
}
```
### Using `GetProductReviews`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getProductReviews, GetProductReviewsVariables } from '@dataconnect/generated';

// The `GetProductReviews` query requires an argument of type `GetProductReviewsVariables`:
const getProductReviewsVars: GetProductReviewsVariables = {
  productId: ..., 
  limit: ..., // optional
};

// Call the `getProductReviews()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getProductReviews(getProductReviewsVars);
// Variables can be defined inline as well.
const { data } = await getProductReviews({ productId: ..., limit: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getProductReviews(dataConnect, getProductReviewsVars);

console.log(data.reviews);

// Or, you can use the `Promise` API.
getProductReviews(getProductReviewsVars).then((response) => {
  const data = response.data;
  console.log(data.reviews);
});
```

### Using `GetProductReviews`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getProductReviewsRef, GetProductReviewsVariables } from '@dataconnect/generated';

// The `GetProductReviews` query requires an argument of type `GetProductReviewsVariables`:
const getProductReviewsVars: GetProductReviewsVariables = {
  productId: ..., 
  limit: ..., // optional
};

// Call the `getProductReviewsRef()` function to get a reference to the query.
const ref = getProductReviewsRef(getProductReviewsVars);
// Variables can be defined inline as well.
const ref = getProductReviewsRef({ productId: ..., limit: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getProductReviewsRef(dataConnect, getProductReviewsVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.reviews);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.reviews);
});
```

## GetUserReviews
You can execute the `GetUserReviews` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getUserReviews(vars: GetUserReviewsVariables): QueryPromise<GetUserReviewsData, GetUserReviewsVariables>;

interface GetUserReviewsRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetUserReviewsVariables): QueryRef<GetUserReviewsData, GetUserReviewsVariables>;
}
export const getUserReviewsRef: GetUserReviewsRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getUserReviews(dc: DataConnect, vars: GetUserReviewsVariables): QueryPromise<GetUserReviewsData, GetUserReviewsVariables>;

interface GetUserReviewsRef {
  ...
  (dc: DataConnect, vars: GetUserReviewsVariables): QueryRef<GetUserReviewsData, GetUserReviewsVariables>;
}
export const getUserReviewsRef: GetUserReviewsRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getUserReviewsRef:
```typescript
const name = getUserReviewsRef.operationName;
console.log(name);
```

### Variables
The `GetUserReviews` query requires an argument of type `GetUserReviewsVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetUserReviewsVariables {
  userId: UUIDString;
}
```
### Return Type
Recall that executing the `GetUserReviews` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetUserReviewsData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetUserReviewsData {
  reviews: ({
    id: UUIDString;
    rating: number;
    title?: string | null;
    comment: string;
    verified: boolean;
    productId: UUIDString;
    createdAt: TimestampString;
  } & Review_Key)[];
}
```
### Using `GetUserReviews`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getUserReviews, GetUserReviewsVariables } from '@dataconnect/generated';

// The `GetUserReviews` query requires an argument of type `GetUserReviewsVariables`:
const getUserReviewsVars: GetUserReviewsVariables = {
  userId: ..., 
};

// Call the `getUserReviews()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getUserReviews(getUserReviewsVars);
// Variables can be defined inline as well.
const { data } = await getUserReviews({ userId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getUserReviews(dataConnect, getUserReviewsVars);

console.log(data.reviews);

// Or, you can use the `Promise` API.
getUserReviews(getUserReviewsVars).then((response) => {
  const data = response.data;
  console.log(data.reviews);
});
```

### Using `GetUserReviews`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getUserReviewsRef, GetUserReviewsVariables } from '@dataconnect/generated';

// The `GetUserReviews` query requires an argument of type `GetUserReviewsVariables`:
const getUserReviewsVars: GetUserReviewsVariables = {
  userId: ..., 
};

// Call the `getUserReviewsRef()` function to get a reference to the query.
const ref = getUserReviewsRef(getUserReviewsVars);
// Variables can be defined inline as well.
const ref = getUserReviewsRef({ userId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getUserReviewsRef(dataConnect, getUserReviewsVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.reviews);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.reviews);
});
```

# Mutations

There are two ways to execute a Data Connect Mutation using the generated Web SDK:
- Using a Mutation Reference function, which returns a `MutationRef`
  - The `MutationRef` can be used as an argument to `executeMutation()`, which will execute the Mutation and return a `MutationPromise`
- Using an action shortcut function, which returns a `MutationPromise`
  - Calling the action shortcut function will execute the Mutation and return a `MutationPromise`

The following is true for both the action shortcut function and the `MutationRef` function:
- The `MutationPromise` returned will resolve to the result of the Mutation once it has finished executing
- If the Mutation accepts arguments, both the action shortcut function and the `MutationRef` function accept a single argument: an object that contains all the required variables (and the optional variables) for the Mutation
- Both functions can be called with or without passing in a `DataConnect` instance as an argument. If no `DataConnect` argument is passed in, then the generated SDK will call `getDataConnect(connectorConfig)` behind the scenes for you.

Below are examples of how to use the `ecommerce` connector's generated functions to execute each mutation. You can also follow the examples from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#using-mutations).

## CreateUser
You can execute the `CreateUser` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
createUser(vars: CreateUserVariables): MutationPromise<CreateUserData, CreateUserVariables>;

interface CreateUserRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateUserVariables): MutationRef<CreateUserData, CreateUserVariables>;
}
export const createUserRef: CreateUserRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createUser(dc: DataConnect, vars: CreateUserVariables): MutationPromise<CreateUserData, CreateUserVariables>;

interface CreateUserRef {
  ...
  (dc: DataConnect, vars: CreateUserVariables): MutationRef<CreateUserData, CreateUserVariables>;
}
export const createUserRef: CreateUserRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createUserRef:
```typescript
const name = createUserRef.operationName;
console.log(name);
```

### Variables
The `CreateUser` mutation requires an argument of type `CreateUserVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateUserVariables {
  firebaseUid: string;
  email: string;
  displayName?: string | null;
  photoURL?: string | null;
}
```
### Return Type
Recall that executing the `CreateUser` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateUserData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateUserData {
  user_insert: User_Key;
}
```
### Using `CreateUser`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createUser, CreateUserVariables } from '@dataconnect/generated';

// The `CreateUser` mutation requires an argument of type `CreateUserVariables`:
const createUserVars: CreateUserVariables = {
  firebaseUid: ..., 
  email: ..., 
  displayName: ..., // optional
  photoURL: ..., // optional
};

// Call the `createUser()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createUser(createUserVars);
// Variables can be defined inline as well.
const { data } = await createUser({ firebaseUid: ..., email: ..., displayName: ..., photoURL: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createUser(dataConnect, createUserVars);

console.log(data.user_insert);

// Or, you can use the `Promise` API.
createUser(createUserVars).then((response) => {
  const data = response.data;
  console.log(data.user_insert);
});
```

### Using `CreateUser`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createUserRef, CreateUserVariables } from '@dataconnect/generated';

// The `CreateUser` mutation requires an argument of type `CreateUserVariables`:
const createUserVars: CreateUserVariables = {
  firebaseUid: ..., 
  email: ..., 
  displayName: ..., // optional
  photoURL: ..., // optional
};

// Call the `createUserRef()` function to get a reference to the mutation.
const ref = createUserRef(createUserVars);
// Variables can be defined inline as well.
const ref = createUserRef({ firebaseUid: ..., email: ..., displayName: ..., photoURL: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createUserRef(dataConnect, createUserVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.user_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.user_insert);
});
```

## UpdateUser
You can execute the `UpdateUser` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
updateUser(vars: UpdateUserVariables): MutationPromise<UpdateUserData, UpdateUserVariables>;

interface UpdateUserRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateUserVariables): MutationRef<UpdateUserData, UpdateUserVariables>;
}
export const updateUserRef: UpdateUserRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateUser(dc: DataConnect, vars: UpdateUserVariables): MutationPromise<UpdateUserData, UpdateUserVariables>;

interface UpdateUserRef {
  ...
  (dc: DataConnect, vars: UpdateUserVariables): MutationRef<UpdateUserData, UpdateUserVariables>;
}
export const updateUserRef: UpdateUserRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateUserRef:
```typescript
const name = updateUserRef.operationName;
console.log(name);
```

### Variables
The `UpdateUser` mutation requires an argument of type `UpdateUserVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateUserVariables {
  firebaseUid: string;
  displayName?: string | null;
  photoURL?: string | null;
}
```
### Return Type
Recall that executing the `UpdateUser` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateUserData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateUserData {
  user_update?: User_Key | null;
}
```
### Using `UpdateUser`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateUser, UpdateUserVariables } from '@dataconnect/generated';

// The `UpdateUser` mutation requires an argument of type `UpdateUserVariables`:
const updateUserVars: UpdateUserVariables = {
  firebaseUid: ..., 
  displayName: ..., // optional
  photoURL: ..., // optional
};

// Call the `updateUser()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateUser(updateUserVars);
// Variables can be defined inline as well.
const { data } = await updateUser({ firebaseUid: ..., displayName: ..., photoURL: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateUser(dataConnect, updateUserVars);

console.log(data.user_update);

// Or, you can use the `Promise` API.
updateUser(updateUserVars).then((response) => {
  const data = response.data;
  console.log(data.user_update);
});
```

### Using `UpdateUser`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateUserRef, UpdateUserVariables } from '@dataconnect/generated';

// The `UpdateUser` mutation requires an argument of type `UpdateUserVariables`:
const updateUserVars: UpdateUserVariables = {
  firebaseUid: ..., 
  displayName: ..., // optional
  photoURL: ..., // optional
};

// Call the `updateUserRef()` function to get a reference to the mutation.
const ref = updateUserRef(updateUserVars);
// Variables can be defined inline as well.
const ref = updateUserRef({ firebaseUid: ..., displayName: ..., photoURL: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateUserRef(dataConnect, updateUserVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.user_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.user_update);
});
```

## CreateProduct
You can execute the `CreateProduct` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
createProduct(vars: CreateProductVariables): MutationPromise<CreateProductData, CreateProductVariables>;

interface CreateProductRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateProductVariables): MutationRef<CreateProductData, CreateProductVariables>;
}
export const createProductRef: CreateProductRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createProduct(dc: DataConnect, vars: CreateProductVariables): MutationPromise<CreateProductData, CreateProductVariables>;

interface CreateProductRef {
  ...
  (dc: DataConnect, vars: CreateProductVariables): MutationRef<CreateProductData, CreateProductVariables>;
}
export const createProductRef: CreateProductRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createProductRef:
```typescript
const name = createProductRef.operationName;
console.log(name);
```

### Variables
The `CreateProduct` mutation requires an argument of type `CreateProductVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateProductVariables {
  name: string;
  slug: string;
  description: string;
  price: number;
  stock: number;
  imageUrl: string;
  categoryId: UUIDString;
  compareAtPrice?: number | null;
  images?: string[] | null;
  sku?: string | null;
}
```
### Return Type
Recall that executing the `CreateProduct` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateProductData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateProductData {
  product_insert: Product_Key;
}
```
### Using `CreateProduct`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createProduct, CreateProductVariables } from '@dataconnect/generated';

// The `CreateProduct` mutation requires an argument of type `CreateProductVariables`:
const createProductVars: CreateProductVariables = {
  name: ..., 
  slug: ..., 
  description: ..., 
  price: ..., 
  stock: ..., 
  imageUrl: ..., 
  categoryId: ..., 
  compareAtPrice: ..., // optional
  images: ..., // optional
  sku: ..., // optional
};

// Call the `createProduct()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createProduct(createProductVars);
// Variables can be defined inline as well.
const { data } = await createProduct({ name: ..., slug: ..., description: ..., price: ..., stock: ..., imageUrl: ..., categoryId: ..., compareAtPrice: ..., images: ..., sku: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createProduct(dataConnect, createProductVars);

console.log(data.product_insert);

// Or, you can use the `Promise` API.
createProduct(createProductVars).then((response) => {
  const data = response.data;
  console.log(data.product_insert);
});
```

### Using `CreateProduct`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createProductRef, CreateProductVariables } from '@dataconnect/generated';

// The `CreateProduct` mutation requires an argument of type `CreateProductVariables`:
const createProductVars: CreateProductVariables = {
  name: ..., 
  slug: ..., 
  description: ..., 
  price: ..., 
  stock: ..., 
  imageUrl: ..., 
  categoryId: ..., 
  compareAtPrice: ..., // optional
  images: ..., // optional
  sku: ..., // optional
};

// Call the `createProductRef()` function to get a reference to the mutation.
const ref = createProductRef(createProductVars);
// Variables can be defined inline as well.
const ref = createProductRef({ name: ..., slug: ..., description: ..., price: ..., stock: ..., imageUrl: ..., categoryId: ..., compareAtPrice: ..., images: ..., sku: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createProductRef(dataConnect, createProductVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.product_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.product_insert);
});
```

## UpdateProduct
You can execute the `UpdateProduct` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
updateProduct(vars: UpdateProductVariables): MutationPromise<UpdateProductData, UpdateProductVariables>;

interface UpdateProductRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateProductVariables): MutationRef<UpdateProductData, UpdateProductVariables>;
}
export const updateProductRef: UpdateProductRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateProduct(dc: DataConnect, vars: UpdateProductVariables): MutationPromise<UpdateProductData, UpdateProductVariables>;

interface UpdateProductRef {
  ...
  (dc: DataConnect, vars: UpdateProductVariables): MutationRef<UpdateProductData, UpdateProductVariables>;
}
export const updateProductRef: UpdateProductRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateProductRef:
```typescript
const name = updateProductRef.operationName;
console.log(name);
```

### Variables
The `UpdateProduct` mutation requires an argument of type `UpdateProductVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateProductVariables {
  id: UUIDString;
  name?: string | null;
  description?: string | null;
  price?: number | null;
  stock?: number | null;
  status?: ProductStatus | null;
}
```
### Return Type
Recall that executing the `UpdateProduct` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateProductData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateProductData {
  product_update?: Product_Key | null;
}
```
### Using `UpdateProduct`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateProduct, UpdateProductVariables } from '@dataconnect/generated';

// The `UpdateProduct` mutation requires an argument of type `UpdateProductVariables`:
const updateProductVars: UpdateProductVariables = {
  id: ..., 
  name: ..., // optional
  description: ..., // optional
  price: ..., // optional
  stock: ..., // optional
  status: ..., // optional
};

// Call the `updateProduct()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateProduct(updateProductVars);
// Variables can be defined inline as well.
const { data } = await updateProduct({ id: ..., name: ..., description: ..., price: ..., stock: ..., status: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateProduct(dataConnect, updateProductVars);

console.log(data.product_update);

// Or, you can use the `Promise` API.
updateProduct(updateProductVars).then((response) => {
  const data = response.data;
  console.log(data.product_update);
});
```

### Using `UpdateProduct`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateProductRef, UpdateProductVariables } from '@dataconnect/generated';

// The `UpdateProduct` mutation requires an argument of type `UpdateProductVariables`:
const updateProductVars: UpdateProductVariables = {
  id: ..., 
  name: ..., // optional
  description: ..., // optional
  price: ..., // optional
  stock: ..., // optional
  status: ..., // optional
};

// Call the `updateProductRef()` function to get a reference to the mutation.
const ref = updateProductRef(updateProductVars);
// Variables can be defined inline as well.
const ref = updateProductRef({ id: ..., name: ..., description: ..., price: ..., stock: ..., status: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateProductRef(dataConnect, updateProductVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.product_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.product_update);
});
```

## DeleteProduct
You can execute the `DeleteProduct` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
deleteProduct(vars: DeleteProductVariables): MutationPromise<DeleteProductData, DeleteProductVariables>;

interface DeleteProductRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteProductVariables): MutationRef<DeleteProductData, DeleteProductVariables>;
}
export const deleteProductRef: DeleteProductRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deleteProduct(dc: DataConnect, vars: DeleteProductVariables): MutationPromise<DeleteProductData, DeleteProductVariables>;

interface DeleteProductRef {
  ...
  (dc: DataConnect, vars: DeleteProductVariables): MutationRef<DeleteProductData, DeleteProductVariables>;
}
export const deleteProductRef: DeleteProductRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deleteProductRef:
```typescript
const name = deleteProductRef.operationName;
console.log(name);
```

### Variables
The `DeleteProduct` mutation requires an argument of type `DeleteProductVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface DeleteProductVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `DeleteProduct` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeleteProductData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeleteProductData {
  product_delete?: Product_Key | null;
}
```
### Using `DeleteProduct`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deleteProduct, DeleteProductVariables } from '@dataconnect/generated';

// The `DeleteProduct` mutation requires an argument of type `DeleteProductVariables`:
const deleteProductVars: DeleteProductVariables = {
  id: ..., 
};

// Call the `deleteProduct()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deleteProduct(deleteProductVars);
// Variables can be defined inline as well.
const { data } = await deleteProduct({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deleteProduct(dataConnect, deleteProductVars);

console.log(data.product_delete);

// Or, you can use the `Promise` API.
deleteProduct(deleteProductVars).then((response) => {
  const data = response.data;
  console.log(data.product_delete);
});
```

### Using `DeleteProduct`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deleteProductRef, DeleteProductVariables } from '@dataconnect/generated';

// The `DeleteProduct` mutation requires an argument of type `DeleteProductVariables`:
const deleteProductVars: DeleteProductVariables = {
  id: ..., 
};

// Call the `deleteProductRef()` function to get a reference to the mutation.
const ref = deleteProductRef(deleteProductVars);
// Variables can be defined inline as well.
const ref = deleteProductRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deleteProductRef(dataConnect, deleteProductVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.product_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.product_delete);
});
```

## CreateCategory
You can execute the `CreateCategory` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
createCategory(vars: CreateCategoryVariables): MutationPromise<CreateCategoryData, CreateCategoryVariables>;

interface CreateCategoryRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateCategoryVariables): MutationRef<CreateCategoryData, CreateCategoryVariables>;
}
export const createCategoryRef: CreateCategoryRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createCategory(dc: DataConnect, vars: CreateCategoryVariables): MutationPromise<CreateCategoryData, CreateCategoryVariables>;

interface CreateCategoryRef {
  ...
  (dc: DataConnect, vars: CreateCategoryVariables): MutationRef<CreateCategoryData, CreateCategoryVariables>;
}
export const createCategoryRef: CreateCategoryRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createCategoryRef:
```typescript
const name = createCategoryRef.operationName;
console.log(name);
```

### Variables
The `CreateCategory` mutation requires an argument of type `CreateCategoryVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateCategoryVariables {
  name: string;
  slug: string;
  description?: string | null;
  imageUrl?: string | null;
  parentId?: UUIDString | null;
}
```
### Return Type
Recall that executing the `CreateCategory` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateCategoryData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateCategoryData {
  category_insert: Category_Key;
}
```
### Using `CreateCategory`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createCategory, CreateCategoryVariables } from '@dataconnect/generated';

// The `CreateCategory` mutation requires an argument of type `CreateCategoryVariables`:
const createCategoryVars: CreateCategoryVariables = {
  name: ..., 
  slug: ..., 
  description: ..., // optional
  imageUrl: ..., // optional
  parentId: ..., // optional
};

// Call the `createCategory()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createCategory(createCategoryVars);
// Variables can be defined inline as well.
const { data } = await createCategory({ name: ..., slug: ..., description: ..., imageUrl: ..., parentId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createCategory(dataConnect, createCategoryVars);

console.log(data.category_insert);

// Or, you can use the `Promise` API.
createCategory(createCategoryVars).then((response) => {
  const data = response.data;
  console.log(data.category_insert);
});
```

### Using `CreateCategory`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createCategoryRef, CreateCategoryVariables } from '@dataconnect/generated';

// The `CreateCategory` mutation requires an argument of type `CreateCategoryVariables`:
const createCategoryVars: CreateCategoryVariables = {
  name: ..., 
  slug: ..., 
  description: ..., // optional
  imageUrl: ..., // optional
  parentId: ..., // optional
};

// Call the `createCategoryRef()` function to get a reference to the mutation.
const ref = createCategoryRef(createCategoryVars);
// Variables can be defined inline as well.
const ref = createCategoryRef({ name: ..., slug: ..., description: ..., imageUrl: ..., parentId: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createCategoryRef(dataConnect, createCategoryVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.category_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.category_insert);
});
```

## UpdateCategory
You can execute the `UpdateCategory` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
updateCategory(vars: UpdateCategoryVariables): MutationPromise<UpdateCategoryData, UpdateCategoryVariables>;

interface UpdateCategoryRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateCategoryVariables): MutationRef<UpdateCategoryData, UpdateCategoryVariables>;
}
export const updateCategoryRef: UpdateCategoryRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateCategory(dc: DataConnect, vars: UpdateCategoryVariables): MutationPromise<UpdateCategoryData, UpdateCategoryVariables>;

interface UpdateCategoryRef {
  ...
  (dc: DataConnect, vars: UpdateCategoryVariables): MutationRef<UpdateCategoryData, UpdateCategoryVariables>;
}
export const updateCategoryRef: UpdateCategoryRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateCategoryRef:
```typescript
const name = updateCategoryRef.operationName;
console.log(name);
```

### Variables
The `UpdateCategory` mutation requires an argument of type `UpdateCategoryVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateCategoryVariables {
  id: UUIDString;
  name?: string | null;
  description?: string | null;
  imageUrl?: string | null;
}
```
### Return Type
Recall that executing the `UpdateCategory` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateCategoryData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateCategoryData {
  category_update?: Category_Key | null;
}
```
### Using `UpdateCategory`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateCategory, UpdateCategoryVariables } from '@dataconnect/generated';

// The `UpdateCategory` mutation requires an argument of type `UpdateCategoryVariables`:
const updateCategoryVars: UpdateCategoryVariables = {
  id: ..., 
  name: ..., // optional
  description: ..., // optional
  imageUrl: ..., // optional
};

// Call the `updateCategory()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateCategory(updateCategoryVars);
// Variables can be defined inline as well.
const { data } = await updateCategory({ id: ..., name: ..., description: ..., imageUrl: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateCategory(dataConnect, updateCategoryVars);

console.log(data.category_update);

// Or, you can use the `Promise` API.
updateCategory(updateCategoryVars).then((response) => {
  const data = response.data;
  console.log(data.category_update);
});
```

### Using `UpdateCategory`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateCategoryRef, UpdateCategoryVariables } from '@dataconnect/generated';

// The `UpdateCategory` mutation requires an argument of type `UpdateCategoryVariables`:
const updateCategoryVars: UpdateCategoryVariables = {
  id: ..., 
  name: ..., // optional
  description: ..., // optional
  imageUrl: ..., // optional
};

// Call the `updateCategoryRef()` function to get a reference to the mutation.
const ref = updateCategoryRef(updateCategoryVars);
// Variables can be defined inline as well.
const ref = updateCategoryRef({ id: ..., name: ..., description: ..., imageUrl: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateCategoryRef(dataConnect, updateCategoryVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.category_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.category_update);
});
```

## AddToCart
You can execute the `AddToCart` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
addToCart(vars: AddToCartVariables): MutationPromise<AddToCartData, AddToCartVariables>;

interface AddToCartRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: AddToCartVariables): MutationRef<AddToCartData, AddToCartVariables>;
}
export const addToCartRef: AddToCartRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
addToCart(dc: DataConnect, vars: AddToCartVariables): MutationPromise<AddToCartData, AddToCartVariables>;

interface AddToCartRef {
  ...
  (dc: DataConnect, vars: AddToCartVariables): MutationRef<AddToCartData, AddToCartVariables>;
}
export const addToCartRef: AddToCartRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the addToCartRef:
```typescript
const name = addToCartRef.operationName;
console.log(name);
```

### Variables
The `AddToCart` mutation requires an argument of type `AddToCartVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface AddToCartVariables {
  userId: UUIDString;
  productId: UUIDString;
  quantity: number;
}
```
### Return Type
Recall that executing the `AddToCart` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `AddToCartData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface AddToCartData {
  cartItem_insert: CartItem_Key;
}
```
### Using `AddToCart`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, addToCart, AddToCartVariables } from '@dataconnect/generated';

// The `AddToCart` mutation requires an argument of type `AddToCartVariables`:
const addToCartVars: AddToCartVariables = {
  userId: ..., 
  productId: ..., 
  quantity: ..., 
};

// Call the `addToCart()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await addToCart(addToCartVars);
// Variables can be defined inline as well.
const { data } = await addToCart({ userId: ..., productId: ..., quantity: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await addToCart(dataConnect, addToCartVars);

console.log(data.cartItem_insert);

// Or, you can use the `Promise` API.
addToCart(addToCartVars).then((response) => {
  const data = response.data;
  console.log(data.cartItem_insert);
});
```

### Using `AddToCart`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, addToCartRef, AddToCartVariables } from '@dataconnect/generated';

// The `AddToCart` mutation requires an argument of type `AddToCartVariables`:
const addToCartVars: AddToCartVariables = {
  userId: ..., 
  productId: ..., 
  quantity: ..., 
};

// Call the `addToCartRef()` function to get a reference to the mutation.
const ref = addToCartRef(addToCartVars);
// Variables can be defined inline as well.
const ref = addToCartRef({ userId: ..., productId: ..., quantity: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = addToCartRef(dataConnect, addToCartVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.cartItem_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.cartItem_insert);
});
```

## UpdateCartItemQuantity
You can execute the `UpdateCartItemQuantity` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
updateCartItemQuantity(vars: UpdateCartItemQuantityVariables): MutationPromise<UpdateCartItemQuantityData, UpdateCartItemQuantityVariables>;

interface UpdateCartItemQuantityRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateCartItemQuantityVariables): MutationRef<UpdateCartItemQuantityData, UpdateCartItemQuantityVariables>;
}
export const updateCartItemQuantityRef: UpdateCartItemQuantityRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateCartItemQuantity(dc: DataConnect, vars: UpdateCartItemQuantityVariables): MutationPromise<UpdateCartItemQuantityData, UpdateCartItemQuantityVariables>;

interface UpdateCartItemQuantityRef {
  ...
  (dc: DataConnect, vars: UpdateCartItemQuantityVariables): MutationRef<UpdateCartItemQuantityData, UpdateCartItemQuantityVariables>;
}
export const updateCartItemQuantityRef: UpdateCartItemQuantityRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateCartItemQuantityRef:
```typescript
const name = updateCartItemQuantityRef.operationName;
console.log(name);
```

### Variables
The `UpdateCartItemQuantity` mutation requires an argument of type `UpdateCartItemQuantityVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateCartItemQuantityVariables {
  id: UUIDString;
  quantity: number;
}
```
### Return Type
Recall that executing the `UpdateCartItemQuantity` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateCartItemQuantityData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateCartItemQuantityData {
  cartItem_update?: CartItem_Key | null;
}
```
### Using `UpdateCartItemQuantity`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateCartItemQuantity, UpdateCartItemQuantityVariables } from '@dataconnect/generated';

// The `UpdateCartItemQuantity` mutation requires an argument of type `UpdateCartItemQuantityVariables`:
const updateCartItemQuantityVars: UpdateCartItemQuantityVariables = {
  id: ..., 
  quantity: ..., 
};

// Call the `updateCartItemQuantity()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateCartItemQuantity(updateCartItemQuantityVars);
// Variables can be defined inline as well.
const { data } = await updateCartItemQuantity({ id: ..., quantity: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateCartItemQuantity(dataConnect, updateCartItemQuantityVars);

console.log(data.cartItem_update);

// Or, you can use the `Promise` API.
updateCartItemQuantity(updateCartItemQuantityVars).then((response) => {
  const data = response.data;
  console.log(data.cartItem_update);
});
```

### Using `UpdateCartItemQuantity`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateCartItemQuantityRef, UpdateCartItemQuantityVariables } from '@dataconnect/generated';

// The `UpdateCartItemQuantity` mutation requires an argument of type `UpdateCartItemQuantityVariables`:
const updateCartItemQuantityVars: UpdateCartItemQuantityVariables = {
  id: ..., 
  quantity: ..., 
};

// Call the `updateCartItemQuantityRef()` function to get a reference to the mutation.
const ref = updateCartItemQuantityRef(updateCartItemQuantityVars);
// Variables can be defined inline as well.
const ref = updateCartItemQuantityRef({ id: ..., quantity: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateCartItemQuantityRef(dataConnect, updateCartItemQuantityVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.cartItem_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.cartItem_update);
});
```

## RemoveFromCart
You can execute the `RemoveFromCart` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
removeFromCart(vars: RemoveFromCartVariables): MutationPromise<RemoveFromCartData, RemoveFromCartVariables>;

interface RemoveFromCartRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: RemoveFromCartVariables): MutationRef<RemoveFromCartData, RemoveFromCartVariables>;
}
export const removeFromCartRef: RemoveFromCartRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
removeFromCart(dc: DataConnect, vars: RemoveFromCartVariables): MutationPromise<RemoveFromCartData, RemoveFromCartVariables>;

interface RemoveFromCartRef {
  ...
  (dc: DataConnect, vars: RemoveFromCartVariables): MutationRef<RemoveFromCartData, RemoveFromCartVariables>;
}
export const removeFromCartRef: RemoveFromCartRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the removeFromCartRef:
```typescript
const name = removeFromCartRef.operationName;
console.log(name);
```

### Variables
The `RemoveFromCart` mutation requires an argument of type `RemoveFromCartVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface RemoveFromCartVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `RemoveFromCart` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `RemoveFromCartData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface RemoveFromCartData {
  cartItem_delete?: CartItem_Key | null;
}
```
### Using `RemoveFromCart`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, removeFromCart, RemoveFromCartVariables } from '@dataconnect/generated';

// The `RemoveFromCart` mutation requires an argument of type `RemoveFromCartVariables`:
const removeFromCartVars: RemoveFromCartVariables = {
  id: ..., 
};

// Call the `removeFromCart()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await removeFromCart(removeFromCartVars);
// Variables can be defined inline as well.
const { data } = await removeFromCart({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await removeFromCart(dataConnect, removeFromCartVars);

console.log(data.cartItem_delete);

// Or, you can use the `Promise` API.
removeFromCart(removeFromCartVars).then((response) => {
  const data = response.data;
  console.log(data.cartItem_delete);
});
```

### Using `RemoveFromCart`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, removeFromCartRef, RemoveFromCartVariables } from '@dataconnect/generated';

// The `RemoveFromCart` mutation requires an argument of type `RemoveFromCartVariables`:
const removeFromCartVars: RemoveFromCartVariables = {
  id: ..., 
};

// Call the `removeFromCartRef()` function to get a reference to the mutation.
const ref = removeFromCartRef(removeFromCartVars);
// Variables can be defined inline as well.
const ref = removeFromCartRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = removeFromCartRef(dataConnect, removeFromCartVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.cartItem_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.cartItem_delete);
});
```

## ClearCart
You can execute the `ClearCart` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
clearCart(vars: ClearCartVariables): MutationPromise<ClearCartData, ClearCartVariables>;

interface ClearCartRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: ClearCartVariables): MutationRef<ClearCartData, ClearCartVariables>;
}
export const clearCartRef: ClearCartRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
clearCart(dc: DataConnect, vars: ClearCartVariables): MutationPromise<ClearCartData, ClearCartVariables>;

interface ClearCartRef {
  ...
  (dc: DataConnect, vars: ClearCartVariables): MutationRef<ClearCartData, ClearCartVariables>;
}
export const clearCartRef: ClearCartRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the clearCartRef:
```typescript
const name = clearCartRef.operationName;
console.log(name);
```

### Variables
The `ClearCart` mutation requires an argument of type `ClearCartVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface ClearCartVariables {
  userId: UUIDString;
}
```
### Return Type
Recall that executing the `ClearCart` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ClearCartData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ClearCartData {
  cartItem_deleteMany: number;
}
```
### Using `ClearCart`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, clearCart, ClearCartVariables } from '@dataconnect/generated';

// The `ClearCart` mutation requires an argument of type `ClearCartVariables`:
const clearCartVars: ClearCartVariables = {
  userId: ..., 
};

// Call the `clearCart()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await clearCart(clearCartVars);
// Variables can be defined inline as well.
const { data } = await clearCart({ userId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await clearCart(dataConnect, clearCartVars);

console.log(data.cartItem_deleteMany);

// Or, you can use the `Promise` API.
clearCart(clearCartVars).then((response) => {
  const data = response.data;
  console.log(data.cartItem_deleteMany);
});
```

### Using `ClearCart`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, clearCartRef, ClearCartVariables } from '@dataconnect/generated';

// The `ClearCart` mutation requires an argument of type `ClearCartVariables`:
const clearCartVars: ClearCartVariables = {
  userId: ..., 
};

// Call the `clearCartRef()` function to get a reference to the mutation.
const ref = clearCartRef(clearCartVars);
// Variables can be defined inline as well.
const ref = clearCartRef({ userId: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = clearCartRef(dataConnect, clearCartVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.cartItem_deleteMany);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.cartItem_deleteMany);
});
```

## CreateOrder
You can execute the `CreateOrder` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
createOrder(vars: CreateOrderVariables): MutationPromise<CreateOrderData, CreateOrderVariables>;

interface CreateOrderRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateOrderVariables): MutationRef<CreateOrderData, CreateOrderVariables>;
}
export const createOrderRef: CreateOrderRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createOrder(dc: DataConnect, vars: CreateOrderVariables): MutationPromise<CreateOrderData, CreateOrderVariables>;

interface CreateOrderRef {
  ...
  (dc: DataConnect, vars: CreateOrderVariables): MutationRef<CreateOrderData, CreateOrderVariables>;
}
export const createOrderRef: CreateOrderRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createOrderRef:
```typescript
const name = createOrderRef.operationName;
console.log(name);
```

### Variables
The `CreateOrder` mutation requires an argument of type `CreateOrderVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateOrderVariables {
  userId: UUIDString;
  orderNumber: string;
  subtotal: number;
  shippingCost: number;
  tax: number;
  total: number;
  shippingName: string;
  shippingAddress: string;
  shippingCity: string;
  shippingPostalCode: string;
  shippingCountry: string;
  billingName: string;
  billingAddress: string;
  billingCity: string;
  billingPostalCode: string;
  billingCountry: string;
  paymentMethod: string;
  paymentStatus: string;
}
```
### Return Type
Recall that executing the `CreateOrder` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateOrderData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateOrderData {
  order_insert: Order_Key;
}
```
### Using `CreateOrder`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createOrder, CreateOrderVariables } from '@dataconnect/generated';

// The `CreateOrder` mutation requires an argument of type `CreateOrderVariables`:
const createOrderVars: CreateOrderVariables = {
  userId: ..., 
  orderNumber: ..., 
  subtotal: ..., 
  shippingCost: ..., 
  tax: ..., 
  total: ..., 
  shippingName: ..., 
  shippingAddress: ..., 
  shippingCity: ..., 
  shippingPostalCode: ..., 
  shippingCountry: ..., 
  billingName: ..., 
  billingAddress: ..., 
  billingCity: ..., 
  billingPostalCode: ..., 
  billingCountry: ..., 
  paymentMethod: ..., 
  paymentStatus: ..., 
};

// Call the `createOrder()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createOrder(createOrderVars);
// Variables can be defined inline as well.
const { data } = await createOrder({ userId: ..., orderNumber: ..., subtotal: ..., shippingCost: ..., tax: ..., total: ..., shippingName: ..., shippingAddress: ..., shippingCity: ..., shippingPostalCode: ..., shippingCountry: ..., billingName: ..., billingAddress: ..., billingCity: ..., billingPostalCode: ..., billingCountry: ..., paymentMethod: ..., paymentStatus: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createOrder(dataConnect, createOrderVars);

console.log(data.order_insert);

// Or, you can use the `Promise` API.
createOrder(createOrderVars).then((response) => {
  const data = response.data;
  console.log(data.order_insert);
});
```

### Using `CreateOrder`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createOrderRef, CreateOrderVariables } from '@dataconnect/generated';

// The `CreateOrder` mutation requires an argument of type `CreateOrderVariables`:
const createOrderVars: CreateOrderVariables = {
  userId: ..., 
  orderNumber: ..., 
  subtotal: ..., 
  shippingCost: ..., 
  tax: ..., 
  total: ..., 
  shippingName: ..., 
  shippingAddress: ..., 
  shippingCity: ..., 
  shippingPostalCode: ..., 
  shippingCountry: ..., 
  billingName: ..., 
  billingAddress: ..., 
  billingCity: ..., 
  billingPostalCode: ..., 
  billingCountry: ..., 
  paymentMethod: ..., 
  paymentStatus: ..., 
};

// Call the `createOrderRef()` function to get a reference to the mutation.
const ref = createOrderRef(createOrderVars);
// Variables can be defined inline as well.
const ref = createOrderRef({ userId: ..., orderNumber: ..., subtotal: ..., shippingCost: ..., tax: ..., total: ..., shippingName: ..., shippingAddress: ..., shippingCity: ..., shippingPostalCode: ..., shippingCountry: ..., billingName: ..., billingAddress: ..., billingCity: ..., billingPostalCode: ..., billingCountry: ..., paymentMethod: ..., paymentStatus: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createOrderRef(dataConnect, createOrderVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.order_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.order_insert);
});
```

## AddOrderItem
You can execute the `AddOrderItem` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
addOrderItem(vars: AddOrderItemVariables): MutationPromise<AddOrderItemData, AddOrderItemVariables>;

interface AddOrderItemRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: AddOrderItemVariables): MutationRef<AddOrderItemData, AddOrderItemVariables>;
}
export const addOrderItemRef: AddOrderItemRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
addOrderItem(dc: DataConnect, vars: AddOrderItemVariables): MutationPromise<AddOrderItemData, AddOrderItemVariables>;

interface AddOrderItemRef {
  ...
  (dc: DataConnect, vars: AddOrderItemVariables): MutationRef<AddOrderItemData, AddOrderItemVariables>;
}
export const addOrderItemRef: AddOrderItemRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the addOrderItemRef:
```typescript
const name = addOrderItemRef.operationName;
console.log(name);
```

### Variables
The `AddOrderItem` mutation requires an argument of type `AddOrderItemVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface AddOrderItemVariables {
  orderId: UUIDString;
  productId: UUIDString;
  quantity: number;
  priceAtTime: number;
  subtotal: number;
}
```
### Return Type
Recall that executing the `AddOrderItem` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `AddOrderItemData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface AddOrderItemData {
  orderItem_insert: OrderItem_Key;
}
```
### Using `AddOrderItem`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, addOrderItem, AddOrderItemVariables } from '@dataconnect/generated';

// The `AddOrderItem` mutation requires an argument of type `AddOrderItemVariables`:
const addOrderItemVars: AddOrderItemVariables = {
  orderId: ..., 
  productId: ..., 
  quantity: ..., 
  priceAtTime: ..., 
  subtotal: ..., 
};

// Call the `addOrderItem()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await addOrderItem(addOrderItemVars);
// Variables can be defined inline as well.
const { data } = await addOrderItem({ orderId: ..., productId: ..., quantity: ..., priceAtTime: ..., subtotal: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await addOrderItem(dataConnect, addOrderItemVars);

console.log(data.orderItem_insert);

// Or, you can use the `Promise` API.
addOrderItem(addOrderItemVars).then((response) => {
  const data = response.data;
  console.log(data.orderItem_insert);
});
```

### Using `AddOrderItem`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, addOrderItemRef, AddOrderItemVariables } from '@dataconnect/generated';

// The `AddOrderItem` mutation requires an argument of type `AddOrderItemVariables`:
const addOrderItemVars: AddOrderItemVariables = {
  orderId: ..., 
  productId: ..., 
  quantity: ..., 
  priceAtTime: ..., 
  subtotal: ..., 
};

// Call the `addOrderItemRef()` function to get a reference to the mutation.
const ref = addOrderItemRef(addOrderItemVars);
// Variables can be defined inline as well.
const ref = addOrderItemRef({ orderId: ..., productId: ..., quantity: ..., priceAtTime: ..., subtotal: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = addOrderItemRef(dataConnect, addOrderItemVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.orderItem_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.orderItem_insert);
});
```

## UpdateOrderStatus
You can execute the `UpdateOrderStatus` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
updateOrderStatus(vars: UpdateOrderStatusVariables): MutationPromise<UpdateOrderStatusData, UpdateOrderStatusVariables>;

interface UpdateOrderStatusRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateOrderStatusVariables): MutationRef<UpdateOrderStatusData, UpdateOrderStatusVariables>;
}
export const updateOrderStatusRef: UpdateOrderStatusRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateOrderStatus(dc: DataConnect, vars: UpdateOrderStatusVariables): MutationPromise<UpdateOrderStatusData, UpdateOrderStatusVariables>;

interface UpdateOrderStatusRef {
  ...
  (dc: DataConnect, vars: UpdateOrderStatusVariables): MutationRef<UpdateOrderStatusData, UpdateOrderStatusVariables>;
}
export const updateOrderStatusRef: UpdateOrderStatusRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateOrderStatusRef:
```typescript
const name = updateOrderStatusRef.operationName;
console.log(name);
```

### Variables
The `UpdateOrderStatus` mutation requires an argument of type `UpdateOrderStatusVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateOrderStatusVariables {
  id: UUIDString;
  status: OrderStatus;
}
```
### Return Type
Recall that executing the `UpdateOrderStatus` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateOrderStatusData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateOrderStatusData {
  order_update?: Order_Key | null;
}
```
### Using `UpdateOrderStatus`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateOrderStatus, UpdateOrderStatusVariables } from '@dataconnect/generated';

// The `UpdateOrderStatus` mutation requires an argument of type `UpdateOrderStatusVariables`:
const updateOrderStatusVars: UpdateOrderStatusVariables = {
  id: ..., 
  status: ..., 
};

// Call the `updateOrderStatus()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateOrderStatus(updateOrderStatusVars);
// Variables can be defined inline as well.
const { data } = await updateOrderStatus({ id: ..., status: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateOrderStatus(dataConnect, updateOrderStatusVars);

console.log(data.order_update);

// Or, you can use the `Promise` API.
updateOrderStatus(updateOrderStatusVars).then((response) => {
  const data = response.data;
  console.log(data.order_update);
});
```

### Using `UpdateOrderStatus`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateOrderStatusRef, UpdateOrderStatusVariables } from '@dataconnect/generated';

// The `UpdateOrderStatus` mutation requires an argument of type `UpdateOrderStatusVariables`:
const updateOrderStatusVars: UpdateOrderStatusVariables = {
  id: ..., 
  status: ..., 
};

// Call the `updateOrderStatusRef()` function to get a reference to the mutation.
const ref = updateOrderStatusRef(updateOrderStatusVars);
// Variables can be defined inline as well.
const ref = updateOrderStatusRef({ id: ..., status: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateOrderStatusRef(dataConnect, updateOrderStatusVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.order_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.order_update);
});
```

## CreateReview
You can execute the `CreateReview` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
createReview(vars: CreateReviewVariables): MutationPromise<CreateReviewData, CreateReviewVariables>;

interface CreateReviewRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateReviewVariables): MutationRef<CreateReviewData, CreateReviewVariables>;
}
export const createReviewRef: CreateReviewRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createReview(dc: DataConnect, vars: CreateReviewVariables): MutationPromise<CreateReviewData, CreateReviewVariables>;

interface CreateReviewRef {
  ...
  (dc: DataConnect, vars: CreateReviewVariables): MutationRef<CreateReviewData, CreateReviewVariables>;
}
export const createReviewRef: CreateReviewRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createReviewRef:
```typescript
const name = createReviewRef.operationName;
console.log(name);
```

### Variables
The `CreateReview` mutation requires an argument of type `CreateReviewVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateReviewVariables {
  productId: UUIDString;
  userId: UUIDString;
  rating: number;
  title?: string | null;
  comment: string;
}
```
### Return Type
Recall that executing the `CreateReview` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateReviewData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateReviewData {
  review_insert: Review_Key;
}
```
### Using `CreateReview`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createReview, CreateReviewVariables } from '@dataconnect/generated';

// The `CreateReview` mutation requires an argument of type `CreateReviewVariables`:
const createReviewVars: CreateReviewVariables = {
  productId: ..., 
  userId: ..., 
  rating: ..., 
  title: ..., // optional
  comment: ..., 
};

// Call the `createReview()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createReview(createReviewVars);
// Variables can be defined inline as well.
const { data } = await createReview({ productId: ..., userId: ..., rating: ..., title: ..., comment: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createReview(dataConnect, createReviewVars);

console.log(data.review_insert);

// Or, you can use the `Promise` API.
createReview(createReviewVars).then((response) => {
  const data = response.data;
  console.log(data.review_insert);
});
```

### Using `CreateReview`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createReviewRef, CreateReviewVariables } from '@dataconnect/generated';

// The `CreateReview` mutation requires an argument of type `CreateReviewVariables`:
const createReviewVars: CreateReviewVariables = {
  productId: ..., 
  userId: ..., 
  rating: ..., 
  title: ..., // optional
  comment: ..., 
};

// Call the `createReviewRef()` function to get a reference to the mutation.
const ref = createReviewRef(createReviewVars);
// Variables can be defined inline as well.
const ref = createReviewRef({ productId: ..., userId: ..., rating: ..., title: ..., comment: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createReviewRef(dataConnect, createReviewVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.review_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.review_insert);
});
```

## UpdateReview
You can execute the `UpdateReview` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
updateReview(vars: UpdateReviewVariables): MutationPromise<UpdateReviewData, UpdateReviewVariables>;

interface UpdateReviewRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateReviewVariables): MutationRef<UpdateReviewData, UpdateReviewVariables>;
}
export const updateReviewRef: UpdateReviewRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateReview(dc: DataConnect, vars: UpdateReviewVariables): MutationPromise<UpdateReviewData, UpdateReviewVariables>;

interface UpdateReviewRef {
  ...
  (dc: DataConnect, vars: UpdateReviewVariables): MutationRef<UpdateReviewData, UpdateReviewVariables>;
}
export const updateReviewRef: UpdateReviewRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateReviewRef:
```typescript
const name = updateReviewRef.operationName;
console.log(name);
```

### Variables
The `UpdateReview` mutation requires an argument of type `UpdateReviewVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateReviewVariables {
  id: UUIDString;
  rating?: number | null;
  title?: string | null;
  comment?: string | null;
}
```
### Return Type
Recall that executing the `UpdateReview` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateReviewData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateReviewData {
  review_update?: Review_Key | null;
}
```
### Using `UpdateReview`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateReview, UpdateReviewVariables } from '@dataconnect/generated';

// The `UpdateReview` mutation requires an argument of type `UpdateReviewVariables`:
const updateReviewVars: UpdateReviewVariables = {
  id: ..., 
  rating: ..., // optional
  title: ..., // optional
  comment: ..., // optional
};

// Call the `updateReview()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateReview(updateReviewVars);
// Variables can be defined inline as well.
const { data } = await updateReview({ id: ..., rating: ..., title: ..., comment: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateReview(dataConnect, updateReviewVars);

console.log(data.review_update);

// Or, you can use the `Promise` API.
updateReview(updateReviewVars).then((response) => {
  const data = response.data;
  console.log(data.review_update);
});
```

### Using `UpdateReview`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateReviewRef, UpdateReviewVariables } from '@dataconnect/generated';

// The `UpdateReview` mutation requires an argument of type `UpdateReviewVariables`:
const updateReviewVars: UpdateReviewVariables = {
  id: ..., 
  rating: ..., // optional
  title: ..., // optional
  comment: ..., // optional
};

// Call the `updateReviewRef()` function to get a reference to the mutation.
const ref = updateReviewRef(updateReviewVars);
// Variables can be defined inline as well.
const ref = updateReviewRef({ id: ..., rating: ..., title: ..., comment: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateReviewRef(dataConnect, updateReviewVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.review_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.review_update);
});
```

## VerifyReview
You can execute the `VerifyReview` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
verifyReview(vars: VerifyReviewVariables): MutationPromise<VerifyReviewData, VerifyReviewVariables>;

interface VerifyReviewRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: VerifyReviewVariables): MutationRef<VerifyReviewData, VerifyReviewVariables>;
}
export const verifyReviewRef: VerifyReviewRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
verifyReview(dc: DataConnect, vars: VerifyReviewVariables): MutationPromise<VerifyReviewData, VerifyReviewVariables>;

interface VerifyReviewRef {
  ...
  (dc: DataConnect, vars: VerifyReviewVariables): MutationRef<VerifyReviewData, VerifyReviewVariables>;
}
export const verifyReviewRef: VerifyReviewRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the verifyReviewRef:
```typescript
const name = verifyReviewRef.operationName;
console.log(name);
```

### Variables
The `VerifyReview` mutation requires an argument of type `VerifyReviewVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface VerifyReviewVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `VerifyReview` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `VerifyReviewData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface VerifyReviewData {
  review_update?: Review_Key | null;
}
```
### Using `VerifyReview`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, verifyReview, VerifyReviewVariables } from '@dataconnect/generated';

// The `VerifyReview` mutation requires an argument of type `VerifyReviewVariables`:
const verifyReviewVars: VerifyReviewVariables = {
  id: ..., 
};

// Call the `verifyReview()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await verifyReview(verifyReviewVars);
// Variables can be defined inline as well.
const { data } = await verifyReview({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await verifyReview(dataConnect, verifyReviewVars);

console.log(data.review_update);

// Or, you can use the `Promise` API.
verifyReview(verifyReviewVars).then((response) => {
  const data = response.data;
  console.log(data.review_update);
});
```

### Using `VerifyReview`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, verifyReviewRef, VerifyReviewVariables } from '@dataconnect/generated';

// The `VerifyReview` mutation requires an argument of type `VerifyReviewVariables`:
const verifyReviewVars: VerifyReviewVariables = {
  id: ..., 
};

// Call the `verifyReviewRef()` function to get a reference to the mutation.
const ref = verifyReviewRef(verifyReviewVars);
// Variables can be defined inline as well.
const ref = verifyReviewRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = verifyReviewRef(dataConnect, verifyReviewVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.review_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.review_update);
});
```

## DeleteReview
You can execute the `DeleteReview` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
deleteReview(vars: DeleteReviewVariables): MutationPromise<DeleteReviewData, DeleteReviewVariables>;

interface DeleteReviewRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteReviewVariables): MutationRef<DeleteReviewData, DeleteReviewVariables>;
}
export const deleteReviewRef: DeleteReviewRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deleteReview(dc: DataConnect, vars: DeleteReviewVariables): MutationPromise<DeleteReviewData, DeleteReviewVariables>;

interface DeleteReviewRef {
  ...
  (dc: DataConnect, vars: DeleteReviewVariables): MutationRef<DeleteReviewData, DeleteReviewVariables>;
}
export const deleteReviewRef: DeleteReviewRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deleteReviewRef:
```typescript
const name = deleteReviewRef.operationName;
console.log(name);
```

### Variables
The `DeleteReview` mutation requires an argument of type `DeleteReviewVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface DeleteReviewVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `DeleteReview` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeleteReviewData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeleteReviewData {
  review_delete?: Review_Key | null;
}
```
### Using `DeleteReview`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deleteReview, DeleteReviewVariables } from '@dataconnect/generated';

// The `DeleteReview` mutation requires an argument of type `DeleteReviewVariables`:
const deleteReviewVars: DeleteReviewVariables = {
  id: ..., 
};

// Call the `deleteReview()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deleteReview(deleteReviewVars);
// Variables can be defined inline as well.
const { data } = await deleteReview({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deleteReview(dataConnect, deleteReviewVars);

console.log(data.review_delete);

// Or, you can use the `Promise` API.
deleteReview(deleteReviewVars).then((response) => {
  const data = response.data;
  console.log(data.review_delete);
});
```

### Using `DeleteReview`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deleteReviewRef, DeleteReviewVariables } from '@dataconnect/generated';

// The `DeleteReview` mutation requires an argument of type `DeleteReviewVariables`:
const deleteReviewVars: DeleteReviewVariables = {
  id: ..., 
};

// Call the `deleteReviewRef()` function to get a reference to the mutation.
const ref = deleteReviewRef(deleteReviewVars);
// Variables can be defined inline as well.
const ref = deleteReviewRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deleteReviewRef(dataConnect, deleteReviewVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.review_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.review_delete);
});
```


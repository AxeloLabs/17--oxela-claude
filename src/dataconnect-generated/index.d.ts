import { ConnectorConfig, DataConnect, QueryRef, QueryPromise, MutationRef, MutationPromise } from 'firebase/data-connect';

export const connectorConfig: ConnectorConfig;

export type TimestampString = string;
export type UUIDString = string;
export type Int64String = string;
export type DateString = string;


export enum OrderStatus {
  PENDING = "PENDING",
  PROCESSING = "PROCESSING",
  SHIPPED = "SHIPPED",
  DELIVERED = "DELIVERED",
  CANCELLED = "CANCELLED",
};

export enum ProductStatus {
  ACTIVE = "ACTIVE",
  INACTIVE = "INACTIVE",
  OUT_OF_STOCK = "OUT_OF_STOCK",
};

export enum UserRole {
  ADMIN = "ADMIN",
  CUSTOMER = "CUSTOMER",
};



export interface AddOrderItemData {
  orderItem_insert: OrderItem_Key;
}

export interface AddOrderItemVariables {
  orderId: UUIDString;
  productId: UUIDString;
  quantity: number;
  priceAtTime: number;
  subtotal: number;
}

export interface AddToCartData {
  cartItem_insert: CartItem_Key;
}

export interface AddToCartVariables {
  userId: UUIDString;
  productId: UUIDString;
  quantity: number;
}

export interface CartItem_Key {
  id: UUIDString;
  __typename?: 'CartItem_Key';
}

export interface Category_Key {
  id: UUIDString;
  __typename?: 'Category_Key';
}

export interface ClearCartData {
  cartItem_deleteMany: number;
}

export interface ClearCartVariables {
  userId: UUIDString;
}

export interface CreateCategoryData {
  category_insert: Category_Key;
}

export interface CreateCategoryVariables {
  name: string;
  slug: string;
  description?: string | null;
  imageUrl?: string | null;
  parentId?: UUIDString | null;
}

export interface CreateOrderData {
  order_insert: Order_Key;
}

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

export interface CreateProductData {
  product_insert: Product_Key;
}

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

export interface CreateReviewData {
  review_insert: Review_Key;
}

export interface CreateReviewVariables {
  productId: UUIDString;
  userId: UUIDString;
  rating: number;
  title?: string | null;
  comment: string;
}

export interface CreateUserData {
  user_insert: User_Key;
}

export interface CreateUserVariables {
  firebaseUid: string;
  email: string;
  displayName?: string | null;
  photoURL?: string | null;
}

export interface DeleteProductData {
  product_delete?: Product_Key | null;
}

export interface DeleteProductVariables {
  id: UUIDString;
}

export interface DeleteReviewData {
  review_delete?: Review_Key | null;
}

export interface DeleteReviewVariables {
  id: UUIDString;
}

export interface GetCartItemWithProductData {
  cartItems: ({
    id: UUIDString;
    quantity: number;
    productId: UUIDString;
    userId: UUIDString;
  } & CartItem_Key)[];
}

export interface GetCartItemWithProductVariables {
  id: UUIDString;
}

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

export interface GetCategoryBySlugVariables {
  slug: string;
}

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

export interface GetOrderByIdVariables {
  orderId: UUIDString;
}

export interface GetOrderItemsData {
  orderItems: ({
    id: UUIDString;
    quantity: number;
    priceAtTime: number;
    subtotal: number;
    productId: UUIDString;
  } & OrderItem_Key)[];
}

export interface GetOrderItemsVariables {
  orderId: UUIDString;
}

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

export interface GetProductBySlugVariables {
  slug: string;
}

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

export interface GetProductReviewsVariables {
  productId: UUIDString;
  limit?: number | null;
}

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

export interface GetProductsByCategoryVariables {
  categoryId: UUIDString;
}

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

export interface GetUserByFirebaseUidVariables {
  firebaseUid: string;
}

export interface GetUserCartData {
  cartItems: ({
    id: UUIDString;
    quantity: number;
    productId: UUIDString;
    createdAt: TimestampString;
  } & CartItem_Key)[];
}

export interface GetUserCartVariables {
  userId: UUIDString;
}

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

export interface GetUserReviewsVariables {
  userId: UUIDString;
}

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

export interface ListAllOrdersVariables {
  status?: OrderStatus | null;
}

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

export interface ListProductsVariables {
  limit?: number | null;
  offset?: number | null;
  categoryId?: UUIDString | null;
}

export interface ListUserOrdersData {
  orders: ({
    id: UUIDString;
    orderNumber: string;
    status: OrderStatus;
    total: number;
    createdAt: TimestampString;
  } & Order_Key)[];
}

export interface ListUserOrdersVariables {
  userId: UUIDString;
}

export interface ListUsersData {
  users: ({
    id: UUIDString;
    email: string;
    displayName?: string | null;
    role: UserRole;
    createdAt: TimestampString;
  } & User_Key)[];
}

export interface OrderItem_Key {
  id: UUIDString;
  __typename?: 'OrderItem_Key';
}

export interface Order_Key {
  id: UUIDString;
  __typename?: 'Order_Key';
}

export interface Product_Key {
  id: UUIDString;
  __typename?: 'Product_Key';
}

export interface RemoveFromCartData {
  cartItem_delete?: CartItem_Key | null;
}

export interface RemoveFromCartVariables {
  id: UUIDString;
}

export interface Review_Key {
  id: UUIDString;
  __typename?: 'Review_Key';
}

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

export interface SearchProductsVariables {
  searchTerm: string;
}

export interface UpdateCartItemQuantityData {
  cartItem_update?: CartItem_Key | null;
}

export interface UpdateCartItemQuantityVariables {
  id: UUIDString;
  quantity: number;
}

export interface UpdateCategoryData {
  category_update?: Category_Key | null;
}

export interface UpdateCategoryVariables {
  id: UUIDString;
  name?: string | null;
  description?: string | null;
  imageUrl?: string | null;
}

export interface UpdateOrderStatusData {
  order_update?: Order_Key | null;
}

export interface UpdateOrderStatusVariables {
  id: UUIDString;
  status: OrderStatus;
}

export interface UpdateProductData {
  product_update?: Product_Key | null;
}

export interface UpdateProductVariables {
  id: UUIDString;
  name?: string | null;
  description?: string | null;
  price?: number | null;
  stock?: number | null;
  status?: ProductStatus | null;
}

export interface UpdateReviewData {
  review_update?: Review_Key | null;
}

export interface UpdateReviewVariables {
  id: UUIDString;
  rating?: number | null;
  title?: string | null;
  comment?: string | null;
}

export interface UpdateUserData {
  user_update?: User_Key | null;
}

export interface UpdateUserVariables {
  firebaseUid: string;
  displayName?: string | null;
  photoURL?: string | null;
}

export interface User_Key {
  id: UUIDString;
  __typename?: 'User_Key';
}

export interface VerifyReviewData {
  review_update?: Review_Key | null;
}

export interface VerifyReviewVariables {
  id: UUIDString;
}

interface GetUserByFirebaseUidRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetUserByFirebaseUidVariables): QueryRef<GetUserByFirebaseUidData, GetUserByFirebaseUidVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetUserByFirebaseUidVariables): QueryRef<GetUserByFirebaseUidData, GetUserByFirebaseUidVariables>;
  operationName: string;
}
export const getUserByFirebaseUidRef: GetUserByFirebaseUidRef;

export function getUserByFirebaseUid(vars: GetUserByFirebaseUidVariables): QueryPromise<GetUserByFirebaseUidData, GetUserByFirebaseUidVariables>;
export function getUserByFirebaseUid(dc: DataConnect, vars: GetUserByFirebaseUidVariables): QueryPromise<GetUserByFirebaseUidData, GetUserByFirebaseUidVariables>;

interface ListUsersRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListUsersData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<ListUsersData, undefined>;
  operationName: string;
}
export const listUsersRef: ListUsersRef;

export function listUsers(): QueryPromise<ListUsersData, undefined>;
export function listUsers(dc: DataConnect): QueryPromise<ListUsersData, undefined>;

interface ListProductsRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars?: ListProductsVariables): QueryRef<ListProductsData, ListProductsVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars?: ListProductsVariables): QueryRef<ListProductsData, ListProductsVariables>;
  operationName: string;
}
export const listProductsRef: ListProductsRef;

export function listProducts(vars?: ListProductsVariables): QueryPromise<ListProductsData, ListProductsVariables>;
export function listProducts(dc: DataConnect, vars?: ListProductsVariables): QueryPromise<ListProductsData, ListProductsVariables>;

interface GetProductBySlugRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetProductBySlugVariables): QueryRef<GetProductBySlugData, GetProductBySlugVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetProductBySlugVariables): QueryRef<GetProductBySlugData, GetProductBySlugVariables>;
  operationName: string;
}
export const getProductBySlugRef: GetProductBySlugRef;

export function getProductBySlug(vars: GetProductBySlugVariables): QueryPromise<GetProductBySlugData, GetProductBySlugVariables>;
export function getProductBySlug(dc: DataConnect, vars: GetProductBySlugVariables): QueryPromise<GetProductBySlugData, GetProductBySlugVariables>;

interface SearchProductsRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: SearchProductsVariables): QueryRef<SearchProductsData, SearchProductsVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: SearchProductsVariables): QueryRef<SearchProductsData, SearchProductsVariables>;
  operationName: string;
}
export const searchProductsRef: SearchProductsRef;

export function searchProducts(vars: SearchProductsVariables): QueryPromise<SearchProductsData, SearchProductsVariables>;
export function searchProducts(dc: DataConnect, vars: SearchProductsVariables): QueryPromise<SearchProductsData, SearchProductsVariables>;

interface ListCategoriesRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListCategoriesData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<ListCategoriesData, undefined>;
  operationName: string;
}
export const listCategoriesRef: ListCategoriesRef;

export function listCategories(): QueryPromise<ListCategoriesData, undefined>;
export function listCategories(dc: DataConnect): QueryPromise<ListCategoriesData, undefined>;

interface GetCategoryBySlugRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetCategoryBySlugVariables): QueryRef<GetCategoryBySlugData, GetCategoryBySlugVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetCategoryBySlugVariables): QueryRef<GetCategoryBySlugData, GetCategoryBySlugVariables>;
  operationName: string;
}
export const getCategoryBySlugRef: GetCategoryBySlugRef;

export function getCategoryBySlug(vars: GetCategoryBySlugVariables): QueryPromise<GetCategoryBySlugData, GetCategoryBySlugVariables>;
export function getCategoryBySlug(dc: DataConnect, vars: GetCategoryBySlugVariables): QueryPromise<GetCategoryBySlugData, GetCategoryBySlugVariables>;

interface GetProductsByCategoryRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetProductsByCategoryVariables): QueryRef<GetProductsByCategoryData, GetProductsByCategoryVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetProductsByCategoryVariables): QueryRef<GetProductsByCategoryData, GetProductsByCategoryVariables>;
  operationName: string;
}
export const getProductsByCategoryRef: GetProductsByCategoryRef;

export function getProductsByCategory(vars: GetProductsByCategoryVariables): QueryPromise<GetProductsByCategoryData, GetProductsByCategoryVariables>;
export function getProductsByCategory(dc: DataConnect, vars: GetProductsByCategoryVariables): QueryPromise<GetProductsByCategoryData, GetProductsByCategoryVariables>;

interface GetUserCartRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetUserCartVariables): QueryRef<GetUserCartData, GetUserCartVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetUserCartVariables): QueryRef<GetUserCartData, GetUserCartVariables>;
  operationName: string;
}
export const getUserCartRef: GetUserCartRef;

export function getUserCart(vars: GetUserCartVariables): QueryPromise<GetUserCartData, GetUserCartVariables>;
export function getUserCart(dc: DataConnect, vars: GetUserCartVariables): QueryPromise<GetUserCartData, GetUserCartVariables>;

interface GetCartItemWithProductRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetCartItemWithProductVariables): QueryRef<GetCartItemWithProductData, GetCartItemWithProductVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetCartItemWithProductVariables): QueryRef<GetCartItemWithProductData, GetCartItemWithProductVariables>;
  operationName: string;
}
export const getCartItemWithProductRef: GetCartItemWithProductRef;

export function getCartItemWithProduct(vars: GetCartItemWithProductVariables): QueryPromise<GetCartItemWithProductData, GetCartItemWithProductVariables>;
export function getCartItemWithProduct(dc: DataConnect, vars: GetCartItemWithProductVariables): QueryPromise<GetCartItemWithProductData, GetCartItemWithProductVariables>;

interface ListUserOrdersRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: ListUserOrdersVariables): QueryRef<ListUserOrdersData, ListUserOrdersVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: ListUserOrdersVariables): QueryRef<ListUserOrdersData, ListUserOrdersVariables>;
  operationName: string;
}
export const listUserOrdersRef: ListUserOrdersRef;

export function listUserOrders(vars: ListUserOrdersVariables): QueryPromise<ListUserOrdersData, ListUserOrdersVariables>;
export function listUserOrders(dc: DataConnect, vars: ListUserOrdersVariables): QueryPromise<ListUserOrdersData, ListUserOrdersVariables>;

interface GetOrderByIdRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetOrderByIdVariables): QueryRef<GetOrderByIdData, GetOrderByIdVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetOrderByIdVariables): QueryRef<GetOrderByIdData, GetOrderByIdVariables>;
  operationName: string;
}
export const getOrderByIdRef: GetOrderByIdRef;

export function getOrderById(vars: GetOrderByIdVariables): QueryPromise<GetOrderByIdData, GetOrderByIdVariables>;
export function getOrderById(dc: DataConnect, vars: GetOrderByIdVariables): QueryPromise<GetOrderByIdData, GetOrderByIdVariables>;

interface GetOrderItemsRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetOrderItemsVariables): QueryRef<GetOrderItemsData, GetOrderItemsVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetOrderItemsVariables): QueryRef<GetOrderItemsData, GetOrderItemsVariables>;
  operationName: string;
}
export const getOrderItemsRef: GetOrderItemsRef;

export function getOrderItems(vars: GetOrderItemsVariables): QueryPromise<GetOrderItemsData, GetOrderItemsVariables>;
export function getOrderItems(dc: DataConnect, vars: GetOrderItemsVariables): QueryPromise<GetOrderItemsData, GetOrderItemsVariables>;

interface ListAllOrdersRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars?: ListAllOrdersVariables): QueryRef<ListAllOrdersData, ListAllOrdersVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars?: ListAllOrdersVariables): QueryRef<ListAllOrdersData, ListAllOrdersVariables>;
  operationName: string;
}
export const listAllOrdersRef: ListAllOrdersRef;

export function listAllOrders(vars?: ListAllOrdersVariables): QueryPromise<ListAllOrdersData, ListAllOrdersVariables>;
export function listAllOrders(dc: DataConnect, vars?: ListAllOrdersVariables): QueryPromise<ListAllOrdersData, ListAllOrdersVariables>;

interface GetProductReviewsRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetProductReviewsVariables): QueryRef<GetProductReviewsData, GetProductReviewsVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetProductReviewsVariables): QueryRef<GetProductReviewsData, GetProductReviewsVariables>;
  operationName: string;
}
export const getProductReviewsRef: GetProductReviewsRef;

export function getProductReviews(vars: GetProductReviewsVariables): QueryPromise<GetProductReviewsData, GetProductReviewsVariables>;
export function getProductReviews(dc: DataConnect, vars: GetProductReviewsVariables): QueryPromise<GetProductReviewsData, GetProductReviewsVariables>;

interface GetUserReviewsRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetUserReviewsVariables): QueryRef<GetUserReviewsData, GetUserReviewsVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetUserReviewsVariables): QueryRef<GetUserReviewsData, GetUserReviewsVariables>;
  operationName: string;
}
export const getUserReviewsRef: GetUserReviewsRef;

export function getUserReviews(vars: GetUserReviewsVariables): QueryPromise<GetUserReviewsData, GetUserReviewsVariables>;
export function getUserReviews(dc: DataConnect, vars: GetUserReviewsVariables): QueryPromise<GetUserReviewsData, GetUserReviewsVariables>;

interface CreateUserRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateUserVariables): MutationRef<CreateUserData, CreateUserVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateUserVariables): MutationRef<CreateUserData, CreateUserVariables>;
  operationName: string;
}
export const createUserRef: CreateUserRef;

export function createUser(vars: CreateUserVariables): MutationPromise<CreateUserData, CreateUserVariables>;
export function createUser(dc: DataConnect, vars: CreateUserVariables): MutationPromise<CreateUserData, CreateUserVariables>;

interface UpdateUserRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateUserVariables): MutationRef<UpdateUserData, UpdateUserVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateUserVariables): MutationRef<UpdateUserData, UpdateUserVariables>;
  operationName: string;
}
export const updateUserRef: UpdateUserRef;

export function updateUser(vars: UpdateUserVariables): MutationPromise<UpdateUserData, UpdateUserVariables>;
export function updateUser(dc: DataConnect, vars: UpdateUserVariables): MutationPromise<UpdateUserData, UpdateUserVariables>;

interface CreateProductRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateProductVariables): MutationRef<CreateProductData, CreateProductVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateProductVariables): MutationRef<CreateProductData, CreateProductVariables>;
  operationName: string;
}
export const createProductRef: CreateProductRef;

export function createProduct(vars: CreateProductVariables): MutationPromise<CreateProductData, CreateProductVariables>;
export function createProduct(dc: DataConnect, vars: CreateProductVariables): MutationPromise<CreateProductData, CreateProductVariables>;

interface UpdateProductRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateProductVariables): MutationRef<UpdateProductData, UpdateProductVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateProductVariables): MutationRef<UpdateProductData, UpdateProductVariables>;
  operationName: string;
}
export const updateProductRef: UpdateProductRef;

export function updateProduct(vars: UpdateProductVariables): MutationPromise<UpdateProductData, UpdateProductVariables>;
export function updateProduct(dc: DataConnect, vars: UpdateProductVariables): MutationPromise<UpdateProductData, UpdateProductVariables>;

interface DeleteProductRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteProductVariables): MutationRef<DeleteProductData, DeleteProductVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: DeleteProductVariables): MutationRef<DeleteProductData, DeleteProductVariables>;
  operationName: string;
}
export const deleteProductRef: DeleteProductRef;

export function deleteProduct(vars: DeleteProductVariables): MutationPromise<DeleteProductData, DeleteProductVariables>;
export function deleteProduct(dc: DataConnect, vars: DeleteProductVariables): MutationPromise<DeleteProductData, DeleteProductVariables>;

interface CreateCategoryRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateCategoryVariables): MutationRef<CreateCategoryData, CreateCategoryVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateCategoryVariables): MutationRef<CreateCategoryData, CreateCategoryVariables>;
  operationName: string;
}
export const createCategoryRef: CreateCategoryRef;

export function createCategory(vars: CreateCategoryVariables): MutationPromise<CreateCategoryData, CreateCategoryVariables>;
export function createCategory(dc: DataConnect, vars: CreateCategoryVariables): MutationPromise<CreateCategoryData, CreateCategoryVariables>;

interface UpdateCategoryRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateCategoryVariables): MutationRef<UpdateCategoryData, UpdateCategoryVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateCategoryVariables): MutationRef<UpdateCategoryData, UpdateCategoryVariables>;
  operationName: string;
}
export const updateCategoryRef: UpdateCategoryRef;

export function updateCategory(vars: UpdateCategoryVariables): MutationPromise<UpdateCategoryData, UpdateCategoryVariables>;
export function updateCategory(dc: DataConnect, vars: UpdateCategoryVariables): MutationPromise<UpdateCategoryData, UpdateCategoryVariables>;

interface AddToCartRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: AddToCartVariables): MutationRef<AddToCartData, AddToCartVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: AddToCartVariables): MutationRef<AddToCartData, AddToCartVariables>;
  operationName: string;
}
export const addToCartRef: AddToCartRef;

export function addToCart(vars: AddToCartVariables): MutationPromise<AddToCartData, AddToCartVariables>;
export function addToCart(dc: DataConnect, vars: AddToCartVariables): MutationPromise<AddToCartData, AddToCartVariables>;

interface UpdateCartItemQuantityRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateCartItemQuantityVariables): MutationRef<UpdateCartItemQuantityData, UpdateCartItemQuantityVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateCartItemQuantityVariables): MutationRef<UpdateCartItemQuantityData, UpdateCartItemQuantityVariables>;
  operationName: string;
}
export const updateCartItemQuantityRef: UpdateCartItemQuantityRef;

export function updateCartItemQuantity(vars: UpdateCartItemQuantityVariables): MutationPromise<UpdateCartItemQuantityData, UpdateCartItemQuantityVariables>;
export function updateCartItemQuantity(dc: DataConnect, vars: UpdateCartItemQuantityVariables): MutationPromise<UpdateCartItemQuantityData, UpdateCartItemQuantityVariables>;

interface RemoveFromCartRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: RemoveFromCartVariables): MutationRef<RemoveFromCartData, RemoveFromCartVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: RemoveFromCartVariables): MutationRef<RemoveFromCartData, RemoveFromCartVariables>;
  operationName: string;
}
export const removeFromCartRef: RemoveFromCartRef;

export function removeFromCart(vars: RemoveFromCartVariables): MutationPromise<RemoveFromCartData, RemoveFromCartVariables>;
export function removeFromCart(dc: DataConnect, vars: RemoveFromCartVariables): MutationPromise<RemoveFromCartData, RemoveFromCartVariables>;

interface ClearCartRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: ClearCartVariables): MutationRef<ClearCartData, ClearCartVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: ClearCartVariables): MutationRef<ClearCartData, ClearCartVariables>;
  operationName: string;
}
export const clearCartRef: ClearCartRef;

export function clearCart(vars: ClearCartVariables): MutationPromise<ClearCartData, ClearCartVariables>;
export function clearCart(dc: DataConnect, vars: ClearCartVariables): MutationPromise<ClearCartData, ClearCartVariables>;

interface CreateOrderRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateOrderVariables): MutationRef<CreateOrderData, CreateOrderVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateOrderVariables): MutationRef<CreateOrderData, CreateOrderVariables>;
  operationName: string;
}
export const createOrderRef: CreateOrderRef;

export function createOrder(vars: CreateOrderVariables): MutationPromise<CreateOrderData, CreateOrderVariables>;
export function createOrder(dc: DataConnect, vars: CreateOrderVariables): MutationPromise<CreateOrderData, CreateOrderVariables>;

interface AddOrderItemRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: AddOrderItemVariables): MutationRef<AddOrderItemData, AddOrderItemVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: AddOrderItemVariables): MutationRef<AddOrderItemData, AddOrderItemVariables>;
  operationName: string;
}
export const addOrderItemRef: AddOrderItemRef;

export function addOrderItem(vars: AddOrderItemVariables): MutationPromise<AddOrderItemData, AddOrderItemVariables>;
export function addOrderItem(dc: DataConnect, vars: AddOrderItemVariables): MutationPromise<AddOrderItemData, AddOrderItemVariables>;

interface UpdateOrderStatusRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateOrderStatusVariables): MutationRef<UpdateOrderStatusData, UpdateOrderStatusVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateOrderStatusVariables): MutationRef<UpdateOrderStatusData, UpdateOrderStatusVariables>;
  operationName: string;
}
export const updateOrderStatusRef: UpdateOrderStatusRef;

export function updateOrderStatus(vars: UpdateOrderStatusVariables): MutationPromise<UpdateOrderStatusData, UpdateOrderStatusVariables>;
export function updateOrderStatus(dc: DataConnect, vars: UpdateOrderStatusVariables): MutationPromise<UpdateOrderStatusData, UpdateOrderStatusVariables>;

interface CreateReviewRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateReviewVariables): MutationRef<CreateReviewData, CreateReviewVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateReviewVariables): MutationRef<CreateReviewData, CreateReviewVariables>;
  operationName: string;
}
export const createReviewRef: CreateReviewRef;

export function createReview(vars: CreateReviewVariables): MutationPromise<CreateReviewData, CreateReviewVariables>;
export function createReview(dc: DataConnect, vars: CreateReviewVariables): MutationPromise<CreateReviewData, CreateReviewVariables>;

interface UpdateReviewRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateReviewVariables): MutationRef<UpdateReviewData, UpdateReviewVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateReviewVariables): MutationRef<UpdateReviewData, UpdateReviewVariables>;
  operationName: string;
}
export const updateReviewRef: UpdateReviewRef;

export function updateReview(vars: UpdateReviewVariables): MutationPromise<UpdateReviewData, UpdateReviewVariables>;
export function updateReview(dc: DataConnect, vars: UpdateReviewVariables): MutationPromise<UpdateReviewData, UpdateReviewVariables>;

interface VerifyReviewRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: VerifyReviewVariables): MutationRef<VerifyReviewData, VerifyReviewVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: VerifyReviewVariables): MutationRef<VerifyReviewData, VerifyReviewVariables>;
  operationName: string;
}
export const verifyReviewRef: VerifyReviewRef;

export function verifyReview(vars: VerifyReviewVariables): MutationPromise<VerifyReviewData, VerifyReviewVariables>;
export function verifyReview(dc: DataConnect, vars: VerifyReviewVariables): MutationPromise<VerifyReviewData, VerifyReviewVariables>;

interface DeleteReviewRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteReviewVariables): MutationRef<DeleteReviewData, DeleteReviewVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: DeleteReviewVariables): MutationRef<DeleteReviewData, DeleteReviewVariables>;
  operationName: string;
}
export const deleteReviewRef: DeleteReviewRef;

export function deleteReview(vars: DeleteReviewVariables): MutationPromise<DeleteReviewData, DeleteReviewVariables>;
export function deleteReview(dc: DataConnect, vars: DeleteReviewVariables): MutationPromise<DeleteReviewData, DeleteReviewVariables>;


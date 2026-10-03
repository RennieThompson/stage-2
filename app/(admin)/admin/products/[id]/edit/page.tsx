import type { Metadata } from "next";
import { Suspense } from "react";

import { PagePlaceholder } from "@/components/shared/page-placeholder";

export const metadata: Metadata = {
  title: "Edit product",
  description: "Edit a product, its variants and its stock.",
};

type EditProductPageProps = {
  params: Promise<{ id: string }>;
};

async function EditProductContent({ params }: EditProductPageProps) {
  const { id } = await params;

  return (
    <PagePlaceholder
      title="Edit product"
      description={`Edit product ${id}: details, images, variants, stock and archive status. Prices change here, never in an order that a customer already placed.`}
      task="Task 8"
    />
  );
}

export default function AdminEditProductPage({ params }: EditProductPageProps) {
  return (
    <Suspense
      fallback={<PagePlaceholder title="Edit product" description="Loading..." />}
    >
      <EditProductContent params={params} />
    </Suspense>
  );
}
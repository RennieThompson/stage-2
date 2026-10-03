import type { Metadata } from "next";
import { Suspense } from "react";

import { PagePlaceholder } from "@/components/shared/page-placeholder";

export const metadata: Metadata = {
  title: "Product details",
  description: "Product details, images and variants.",
};

type ProductPageProps = {
  params: Promise<{ slug: string }>;
};

async function ProductContent({ params }: ProductPageProps) {
  const { slug } = await params;

  return (
    <PagePlaceholder
      title="Product details"
      description={`Images, description, prices from the database and variant options for "${slug}". Add to cart arrives in Task 4.`}
      task="Task 3"
    />
  );
}

export default function ProductPage({ params }: ProductPageProps) {
  return (
    <Suspense
      fallback={
        <PagePlaceholder title="Product details" description="Loading..." />
      }
    >
      <ProductContent params={params} />
    </Suspense>
  );
}
import type { Metadata } from "next";
import { Suspense } from "react";

import { PagePlaceholder } from "@/components/shared/page-placeholder";

export const metadata: Metadata = {
  title: "Category",
  description: "Products in a category.",
};

type CategoryPageProps = {
  params: Promise<{ slug: string }>;
};

async function CategoryContent({ params }: CategoryPageProps) {
  const { slug } = await params;

  return (
    <PagePlaceholder
      title="Category"
      description={`Every product in the "${slug}" category. Categories are read from the database, so this slug resolves a real category row.`}
      task="Task 3"
    />
  );
}

export default function CategoryPage({ params }: CategoryPageProps) {
  return (
    <Suspense
      fallback={<PagePlaceholder title="Category" description="Loading..." />}
    >
      <CategoryContent params={params} />
    </Suspense>
  );
}
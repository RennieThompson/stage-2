import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";

type PagePlaceholderProps = {
  /** Page name, used as the `h1`. */
  title: string;
  /** One or two sentences about what this page will do. */
  description: string;
  /** The task that builds the real page, for example "Task 3". */
  task?: string;
  className?: string;
};

/**
 * Temporary content for every route in PRD section 19. Each page replaces this
 * with its real implementation in a later task.
 */
export function PagePlaceholder({
  title,
  description,
  task,
  className,
}: PagePlaceholderProps) {
  return (
    <section
      className={cn("mx-auto w-full max-w-3xl px-4 py-12 sm:px-6", className)}
    >
      <div className="flex flex-col gap-4">
        <Badge variant="secondary" className="w-fit font-normal">
          Placeholder
        </Badge>
        <h1 className="text-3xl font-semibold tracking-tight sm:text-4xl">
          {title}
        </h1>
        <p className="text-base text-muted-foreground">{description}</p>
        {task ? (
          <p className="text-sm text-muted-foreground">
            Built in{" "}
            <span className="font-medium text-foreground">{task}</span>.
          </p>
        ) : null}
        <div
          aria-hidden="true"
          className="mt-4 h-px w-full bg-gradient-to-r from-primary/60 via-secondary to-transparent"
        />
      </div>
    </section>
  );
}
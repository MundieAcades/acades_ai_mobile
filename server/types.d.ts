declare module "https://deno.land/std@0.201.0/http/server.ts" {
  export function serve(handler: (req: Request) => Response | Promise<Response>): void;
}

declare module "https://esm.sh/@supabase/supabase-js@2.30.0" {
  export interface SupabaseClient {
    from(table: string): any;
    rpc(name: string, args?: Record<string, unknown>): Promise<{ data: any; error: any }>;
  }

  export function createClient(url: string, key: string): SupabaseClient;
}

declare const Deno: {
  env: {
    get(name: string): string | undefined;
  };
};

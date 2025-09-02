import {z} from 'zod'

// We're keeping a simple non-relational schema here.
// IRL, you will have a schema for your data models.
export const logSchema = z.object({
    message: z.string(),
    logLevel: z.string(),
    example: z.string(),
    error: z.string(),
    stackTrace: z.string(),
    title: z.string(),
    time: z.string(),
})

export type Log = z.infer<typeof logSchema>

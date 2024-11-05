-- nix-shell -p 'lua.withPackages(ps: with ps; [ lpeg inspect ])' entr
-- ls *.lua | entr lua test.lua

local inspect = require("inspect")
local swagda = require("main")

local sample =
	"((ϵ (F.F₀ (G.F₀ (F.F₀ _))) D.∘ F.F₁ C.id D.∘ ϵ (F.F₀ (G.F₀ (F.F₀ (G.F₀ (F.F₀ _)))))) D.∘ F.F₁ (G.F₁ (ϵ (F.F₀ (G.F₀ (F.F₀ (G.F₀ (F.F₀ _))))) D.∘ F.F₁ (η (G.F₀ (F.F₀ (G.F₀ (F.F₀ _)))) C.∘ G.F₁ (ϵ (F.F₀ (G.F₀ (F.F₀ _)))) C.∘ η (G.F₀ (F.F₀ (G.F₀ (F.F₀ _))))) D.∘ ϵ (F.F₀ (G.F₀ (F.F₀ (G.F₀ (F.F₀ _))))))) D.∘ F.F₁ (η (G.F₀ (F.F₀ (G.F₀ (F.F₀ (G.F₀ (F.F₀ _)))))))) D.∘ F.F₁ (G.F₁ (((ϵ (F.F₀ (G.F₀ (F.F₀ (G.F₀ (F.F₀ _))))) D.∘ F.F₁ C.id D.∘ ϵ (F.F₀ (G.F₀ (F.F₀ (G.F₀ (F.F₀ (G.F₀ (F.F₀ _)))))))) D.∘ F.F₁ (G.F₁ (ϵ (F.F₀ (G.F₀ (F.F₀ (G.F₀ (F.F₀ (G.F₀ (F.F₀ _))))))) D.∘ F.F₁ (η (G.F₀ (F.F₀ (G.F₀ (F.F₀ (G.F₀ (F.F₀ _)))))) C.∘ G.F₁ (D.id D.∘ F.F₁ (G.F₁ ((ϵ (F.F₀ (G.F₀ (F.F₀ _))) D.∘ F.F₁ f D.∘ ϵ (F.F₀ (G.F₀ (F.F₀ _)))) D.∘ F.F₁ (G.F₁ D.id) D.∘ F.F₁ (η (G.F₀ (F.F₀ _))))) D.∘ F.F₁ (η (G.F₀ (F.F₀ _)))) C.∘ η (G.F₀ (F.F₀ _))) D.∘ ϵ (F.F₀ (G.F₀ (F.F₀ _))))) D.∘ F.F₁ (η (G.F₀ (F.F₀ (G.F₀ (F.F₀ _)))))) D.∘ F.F₁ (G.F₁ (ϵ (F.F₀ (G.F₀ (F.F₀ _))))) D.∘ F.F₁ (η (G.F₀ (F.F₀ (G.F₀ (F.F₀ _))))))) D.∘ F.F₁ (η (G.F₀ (F.F₀ (G.F₀ (F.F₀ _)))))"
sample =
	"((ϵ (F (G (F _))) ∘ F.F C.id D.∘ ϵ (Q.F (G (F (G (F _)))))) ∘ F (G (ϵ (F (G (F (G (F _))))) ∘ F (η (G (F (G (F _)))) ∘ G (ϵ (F (G (F _)))) ∘ η (G (F (G (F _))))) ∘ ϵ (F (G (F (G (F _))))))) ∘ F (η (G (F (G (F (G (F _)))))))) ∘ F (G (((ϵ (F (G (F (G (F _))))) ∘ F id ∘ ϵ (F (G (F (G (F (G (F _)))))))) ∘ F (G (ϵ (F (G (F (G (F (G (F _))))))) ∘ F (η (G (F (G (F (G (F _)))))) ∘ G (id ∘ F (G ((ϵ (F (G (F _))) ∘ F f ∘ ϵ (F (G (F _)))) ∘ F (G id) ∘ F (η (G (F _))))) ∘ F (η (G (F _)))) ∘ η (G (F _))) ∘ ϵ (F (G (F _))))) ∘ F (η (G (F (G (F _)))))) ∘ F (G (ϵ (F (G (F _))))) ∘ F (η (G (F (G (F _))))))) ∘ F (η (G (F (G (F _)))))"
sample = "G (F ((G (ϵ (F.F₀ (G (F (G _))))) D.∘ G.F₁ (F 1)) ∘ (G (F (η (G (F (G (F (G _))))) ∘ G f)))))"
sample = "G (F (η (G (F (G (F (G _))))) ∘ G f)) ∘ (G _)"
-- sample = "G (ϵ (F (G (F (G _))))) ∘ G (F 1)"
-- sample = "G (F _) ∘ (G _)"
-- sample = "G (F (G ∘ (H 1)))"
-- sample = "F (G _ ∘ (H 1))"
-- sample = "F(X ∘ (Y ∘ A) ∘ Z)"
-- sample = "F(X ∘ Y)"
-- sample = "F A ∘ X"
-- sample = "A.W (C.X _)"
-- sample = "A B C ∘ D E _"

ast = swagda.parse(sample)

print("========================================")
print("PARSED AST:")
print(inspect(ast))
print("INPUT STRING:")
print(sample)
print("UNPARSED STRING:")
print(swagda.unparse(ast))
print("RESTRUCTURED STRING:")
print(swagda.unparse(swagda.distribute(ast)))

﻿using Domain.Helpers;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface ICategoriaPago
    {
        List<CategoriaPago> Find();
        CategoriaPago Find(int categoriaId);
        Response Save(CategoriaPago categoriaPago, int currentUserId, SaveOption saveOption);
        Response ChangeState(int categoriaId, bool currentState, int currentUserId);

        List<ConceptoEntity> GetConceptos(int categoriaId);
        Response ConceptosSave(int categoriaId, List<int> conceptos);
    }
}

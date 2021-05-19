using Domain.Helpers;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IClasificadores
    {
        List<ClasificadorPresupuestal> Find(string anio);
        ClasificadorPresupuestal Find(int clasificadorId);
        Response Save(ClasificadorPresupuestal clasificadorDeIngreso, int currentUserId, SaveOption saveOption);
        Response ChangeState(int clasificadorId, bool currentState, int currentUserId);

    }
}

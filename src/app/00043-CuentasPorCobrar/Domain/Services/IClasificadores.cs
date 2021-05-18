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
        List<ClasificadorDeIngreso> Find(string anio);
        ClasificadorDeIngreso Find(int clasificadorId);
        Response Save(ClasificadorDeIngreso clasificadorDeIngreso, int currentUserId, SaveOption saveOption);
        Response ChangeState(int clasificadorId, bool currentState, int currentUserId);

    }
}

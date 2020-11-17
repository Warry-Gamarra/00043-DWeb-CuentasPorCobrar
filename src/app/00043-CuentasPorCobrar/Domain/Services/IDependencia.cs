using Domain.DTO;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IDependencia
    {
        List<Dependencia> Find();
        Dependencia Find(int dependenciaId);
        Response Save(Dependencia dependencia, int currentUserId, SaveOption saveOption);
        Response ChangeState(int dependenciaId, bool currentState, int currentUserId);

    }
}

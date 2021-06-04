using Domain.Helpers;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IEntidadRecaudadora
    {
        List<EntidadRecaudadora> Find();
        EntidadRecaudadora Find(int entidadRecaudadoraId);
        Response Save(EntidadRecaudadora entidadRecaudadora, int currentUserId, SaveOption saveOption);
        Response ChangeState(int entidadRecaudadoraId, bool currentState, int currentUserId);
        Response HabilitarArchivos(int entidadRecaudadoraId, int currentUserId);
    }
}
